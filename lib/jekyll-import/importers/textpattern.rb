module JekyllImport
  module Importers
    class TextPattern < Importer
      # Reads a MySQL database via Sequel and creates a post file for each post.
      # The only posts selected are those with a status of 4 or 5, which means
      # "live" and "sticky" respectively.
      # Other statuses are 1 => draft, 2 => hidden and 3 => pending.
      QUERY = "SELECT Title, \
                      url_title, \
                      Posted, \
                      Body, \
                      Keywords \
               FROM textpattern \
               WHERE Status = '4' OR \
                     Status = '5'"

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          sequel
          fileutils
          safe_yaml
        ])
      end

      def self.specify_options(c)
        c.option 'dbname', '--dbname DB', 'Database name'
        c.option 'user', '--user USER', 'Database user name'
        c.option 'password', '--password PW', "Database user's password"
        c.option 'host', '--host HOST', 'Database host name (default: "localhost")'
      end

      def self.process(options)
        dbname = options.fetch('dbname')
        user   = options.fetch('user')
        pass   = options.fetch('password', "")
        host   = options.fetch('host', "localhost")

        db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')

        FileUtils.mkdir_p "_posts"

        db[QUERY].each do |post|
          # Get required fields and construct Jekyll compatible name.
          title = post[:Title]
          slug = post[:url_title]
          date = post[:Posted]
          content = post[:Body]

          name = [date.strftime("%Y-%m-%d"), slug].join('-') + ".textile"

          # Get the relevant fields as a hash, delete empty fields and convert
          # to YAML for the header.
          data = {
             'layout' => 'post',
             'title' => title.to_s,
             'tags' => post[:Keywords].split(',')
           }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

          # Write out the data and content to file.
          File.open("_posts/#{name}", "w") do |f|
            f.puts data
            f.puts "---"
            f.puts content
          end
        end
      end
    end
  end
end
