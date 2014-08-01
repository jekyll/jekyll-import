module JekyllImport
  module Importers
    class Mephisto < Importer
      #Accepts a hash with database config variables, exports mephisto posts into a csv
      #export PGPASSWORD if you must
      def self.postgres(c)
        sql = <<-SQL
        BEGIN;
        CREATE TEMP TABLE jekyll AS
          SELECT title, permalink, body, published_at, filter FROM contents
          WHERE user_id = 1 AND type = 'Article' ORDER BY published_at;
        COPY jekyll TO STDOUT WITH CSV HEADER;
        ROLLBACK;
        SQL
        command = %Q(psql -h #{c[:host] || "localhost"} -c "#{sql.strip}" #{c[:database]} #{c[:username]} -o #{c[:filename] || "posts.csv"})
        puts command
        `#{command}`
        CSV.process
      end

      def self.validate(options)
        %w[dbname user].each do |option|
          if options[option].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          sequel
          fastercsv
          fileutils
        ])
      end

      def self.specify_options(c)
        c.option 'dbname', '--dbname DB', 'Database name'
        c.option 'user', '--user USER', 'Database user name'
        c.option 'password', '--password PW', "Database user's password (default: '')"
        c.option 'host', '--host HOST', 'Database host name (default: "localhost")'
      end

      # This query will pull blog posts from all entries across all blogs. If
      # you've got unpublished, deleted or otherwise hidden posts please sift
      # through the created posts to make sure nothing is accidently published.
      QUERY = "SELECT id, \
                      permalink, \
                      body, \
                      published_at, \
                      title \
               FROM contents \
               WHERE user_id = 1 AND \
                     type = 'Article' AND \
                     published_at IS NOT NULL \
               ORDER BY published_at"

      def self.process(options)
        dbname = options.fetch('dbname')
        user   = options.fetch('user')
        pass   = options.fetch('password', '')
        host   = options.fetch('host', "localhost")

        db = Sequel.mysql(dbname, :user => user,
                                  :password => pass,
                                  :host => host,
                                  :encoding => 'utf8')

        FileUtils.mkdir_p "_posts"

        db[QUERY].each do |post|
          title = post[:title]
          slug = post[:permalink]
          date = post[:published_at]
          content = post[:body]

          # Ideally, this script would determine the post format (markdown,
          # html, etc) and create files with proper extensions. At this point
          # it just assumes that markdown will be acceptable.
          name = [date.year, date.month, date.day, slug].join('-') + ".markdown"

          data = {
             'layout' => 'post',
             'title' => title.to_s,
             'mt_id' => post[:entry_id],
           }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

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