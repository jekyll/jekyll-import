# NOTE: This migrator is made for Ghost sqlite databases.
module JekyllImport
  module Importers
    class Ghost < Importer
      def self.validate(options)
        %w[dbfile].each do |option|
          if options[option].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.specify_options(c)
        c.option 'dbfile', '--dbfile', 'Database file'
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
        dbfile = options.fetch('dbfile')
        db = Sequel.sqlite(dbfile)
        db.test_connection

        FileUtils.mkdir_p("_posts")

        # Reads a SQLite database via Sequel and creates a post file for each post
        query = "SELECT `title`, `slug`, `markdown`, `created_at`, `uuid` FROM posts WHERE status = 'draft' OR status = 'published'"

        db[query].each do |post|
          # Get required fields and construct Jekyll compatible name.
          title = post[:title]
          slug = post[:slug]
          # Ghost saves the time in a weird format, so we have to cut the last 3 numbers
          date = Time.at(post[:created_at].to_i.to_s[0..-4].to_i)
          content = post[:markdown]
          name = "%02d-%02d-%02d-%s.markdown" % [date.year, date.month, date.day,
                                                 slug]

          # Get the relevant fields as a hash, delete empty fields and convert
          # to YAML for the header.
          data = {
             'layout' => 'post',
             'title' => title.to_s,
             'uuid' => post[:uuid],
             'status' => post[:status],
             'date' => date
           }.delete_if { |k,v| v.nil? || v == '' }.to_yaml

          # Write out the data and content to file
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
