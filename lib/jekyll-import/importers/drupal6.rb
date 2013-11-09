# NOTE: This converter requires Sequel and the MySQL gems.
# The MySQL gem can be difficult to install on OS X. Once you have MySQL
# installed, running the following commands should work:
# $ sudo gem install sequel
# $ sudo gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config

module JekyllImport
  module Importers
    class Drupal6 < Importer
      # Reads a MySQL database via Sequel and creates a post file for each story
      # and blog node.
      QUERY = "SELECT n.nid, \
                      n.title, \
                      nr.body, \
                      n.created, \
                      n.status, \
                      GROUP_CONCAT( td.name SEPARATOR '|' ) AS 'tags' \
                 FROM node_revisions AS nr, \
                      node AS n \
                 LEFT OUTER JOIN term_node AS tn ON tn.nid = n.nid \
                 LEFT OUTER JOIN term_data AS td ON tn.tid = td.tid \
                WHERE (n.type = 'blog' OR n.type = 'story' OR n.type = 'article') \
                  AND n.vid = nr.vid \
             GROUP BY n.nid"

      def self.validate(options)
        %w[dbname user].each do |option|
          if options[option.to_sym].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.specify_options(c)
        c.option 'dbname', '--dbname DB', 'Database name'
        c.option 'user', '--user USER', 'Database user name'
        c.option 'password', '--password PW', "Database user's password (default: '')"
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

        if prefix != ''
          QUERY[" node "] = " " + prefix + "node "
          QUERY[" node_revisions "] = " " + prefix + "node_revisions "
          QUERY[" term_node "] = " " + prefix + "term_node "
          QUERY[" term_data "] = " " + prefix + "term_data "
        end

        FileUtils.mkdir_p "_posts"
        FileUtils.mkdir_p "_drafts"
        FileUtils.mkdir_p "_layouts"

        # Create the refresh layout
        # Change the refresh url if you customized your permalink config
        File.open("_layouts/refresh.html", "w") do |f|
          f.puts <<EOF
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta http-equiv="refresh" content="0;url={{ page.refresh_to_post_id }}.html" />
</head>
</html>
EOF
        end

        db[QUERY].each do |post|
          # Get required fields and construct Jekyll compatible name
          node_id = post[:nid]
          title = post[:title]
          content = post[:body]
          tags = post.fetch(:tags, '').downcase.strip
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
             'categories' => tags.split('|')
           }.delete_if { |k,v| v.nil? || v == ''}.each_pair {
              |k,v| ((v.is_a? String) ? v.force_encoding("UTF-8") : v)
           }.to_yaml

          # Write out the data and content to file
          File.open("#{dir}/#{name}", "w") do |f|
            f.puts data
            f.puts "---"
            f.puts content
          end

          # Make a file to redirect from the old Drupal URL
          if is_published
            aliases = db["SELECT dst FROM #{prefix}url_alias WHERE src = ?", "node/#{node_id}"].all

            aliases.push(:dst => "node/#{node_id}")

            aliases.each do |url_alias|
              FileUtils.mkdir_p url_alias[:dst]
              File.open("#{url_alias[:dst]}/index.md", "w") do |f|
                f.puts "---"
                f.puts "layout: refresh"
                f.puts "refresh_to_post_id: /#{time.strftime("%Y/%m/%d/") + slug}"
                f.puts "---"
              end
            end
          end
        end

        # TODO: Make dirs & files for nodes of type 'page'
        # Make refresh pages for these as well
      end
    end
  end
end
