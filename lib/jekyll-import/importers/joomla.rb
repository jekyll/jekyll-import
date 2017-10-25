module JekyllImport
  module Importers
    class Joomla < Importer
      def self.validate(options)
        %w(dbname user).each do |option|
          if options[option].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.specify_options(c)
        c.option "dbname", "--dbname", "Database name"
        c.option "user", "--user", "Database user name"
        c.option "password", "--password", "Database user's password (default: '')"
        c.option "host", "--host", "Database host name"
        c.option "port", "--port", "Database port"
        c.option "section", "--section", "Table prefix name"
        c.option "prefix", "--prefix", "Table prefix name"
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          rubygems
          sequel
          mysql2
          fileutils
          safe_yaml
        ))
      end

      def self.process(options)
        dbname  = options.fetch("dbname")
        user    = options.fetch("user")
        pass    = options.fetch("password", "")
        host    = options.fetch("host", "localhost")
        port    = options.fetch("port", 3306).to_i
        section = options.fetch("section", "1")
        table_prefix = options.fetch("prefix", "jos_")

        db = Sequel.mysql2(dbname, :user => user, :password => pass, :host => host, :port => port, :encoding => "utf8")

        FileUtils.mkdir_p("_posts")

        # Reads a MySQL database via Sequel and creates a post file for each
        # post in wp_posts that has post_status = 'publish'. This restriction is
        # made because 'draft' posts are not guaranteed to have valid dates.
        query = "SELECT `title`, `alias`, CONCAT(`introtext`,`fulltext`) as content, `created`, `id` FROM #{table_prefix}content WHERE (state = '0' OR state = '1') AND sectionid = '#{section}'"

        db[query].each do |post|
          # Get required fields and construct Jekyll compatible name.
          title = post[:title]
          date = post[:created]
          content = post[:content]
          id = post[:id]

          # Construct a slug from the title if alias field empty.
          # Remove illegal filename characters.
          slug = if !post[:alias] || post[:alias].empty?
                   sluggify(post[:title])
                 else
                   sluggify(post[:alias])
                 end

          name = format("%02d-%02d-%02d-%03d-%s.markdown", date.year, date.month, date.day, id, slug)

          # Get the relevant fields as a hash, delete empty fields and convert
          # to YAML for the header.
          data = {
            "layout"     => "post",
            "title"      => title.to_s,
            "joomla_id"  => post[:id],
            "joomla_url" => post[:alias],
            "date"       => date,
          }.delete_if { |_k, v| v.nil? || v == "" }.to_yaml

          # Write out the data and content to file
          File.open("_posts/#{name}", "w") do |f|
            f.puts data
            f.puts "---"
            f.puts content
          end
        end
      end

      # Borrowed from the Wordpress importer
      def self.sluggify(title)
        title.downcase.gsub(%r![^0-9A-Za-z]+!, " ").strip.tr(" ", "-")
      end
    end
  end
end
