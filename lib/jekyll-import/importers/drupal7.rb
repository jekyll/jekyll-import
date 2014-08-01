module JekyllImport
  module Importers
    class Drupal7 < Importer
      # Reads a MySQL database via Sequel and creates a post file for each story
      # and blog node.
      QUERY = "SELECT n.nid, \
                      n.title, \
                      fdb.body_value, \
                      n.created, \
                      n.status \
               FROM node AS n, \
                    field_data_body AS fdb \
               WHERE (n.type = 'blog' OR n.type = 'story' OR n.type = 'article') \
               AND n.nid = fdb.entity_id \
               AND n.vid = fdb.revision_id"

      def self.validate(options)
        %w[dbname user].each do |option|
          if options[option].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.specify_options(c)
        c.option 'dbname', '--dbname DB', 'Database name'
        c.option 'user', '--user USER', 'Database user name'
        c.option 'password', '--password PW', 'Database user\'s password (default: "")'
        c.option 'host', '--host HOST', 'Database host name (default: "localhost")'
        c.option 'prefix', '--prefix PREFIX', 'Table prefix name'
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          sequel
          fileutils
          safe_yaml
        ])
      end

      def self.process(options)
        dbname = options.fetch('dbname')
        user   = options.fetch('user')
        pass   = options.fetch('password', "")
        host   = options.fetch('host', "localhost")
        prefix = options.fetch('prefix', "")

        db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')

        unless prefix.empty?
          QUERY[" node "] = " " + prefix + "node "
          QUERY[" field_data_body "] = " " + prefix + "field_data_body "
        end

        FileUtils.mkdir_p "_posts"
        FileUtils.mkdir_p "_drafts"
        FileUtils.mkdir_p "_layouts"

        db[QUERY].each do |post|
          # Get required fields and construct Jekyll compatible name
          node_id = post[:nid]
          title = post[:title]
          content = post[:body_value]
          created = post[:created]
          time = Time.at(created)
          is_published = post[:status] == 1
          dir = is_published ? "_posts" : "_drafts"
          slug = title.strip.downcase.gsub(/(&|&amp;)/, ' and ').gsub(/[\s\.\/\\]/, '-').gsub(/[^\w-]/, '').gsub(/[-_]{2,}/, '-').gsub(/^[-_]/, '').gsub(/[-_]$/, '')
          name = time.strftime("%Y-%m-%d-") + slug + '.md'

          # Get the relevant fields as a hash, delete empty fields and convert
          # to YAML for the header
          data = {
             'layout' => 'post',
             'title' => title.to_s,
             'created' => created,
           }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

          # Write out the data and content to file
          File.open("#{dir}/#{name}", "w") do |f|
            f.puts data
            f.puts "---"
            f.puts content
          end

        end

        # TODO: Make dirs & files for nodes of type 'page'
          # Make refresh pages for these as well

        # TODO: Make refresh dirs & files according to entries in url_alias table
      end
    end
  end
end
