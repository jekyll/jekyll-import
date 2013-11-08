require 'rubygems'
require 'sequel'
require 'fileutils'
require 'safe_yaml'

# NOTE: This migrator is made for Joomla 1.5 databases.
# NOTE: This converter requires Sequel and the MySQL gems.
# The MySQL gem can be difficult to install on OS X. Once you have MySQL
# installed, running the following commands should work:
# $ sudo gem install sequel
# $ sudo gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config

module JekyllImport
  module Importers
    class Joomla < Importer
      def self.validate(options)
        %w[dbname user pass].each do |option|
          if options[option.to_sym].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.process(options)
        dbname  = options.fetch(:dbname)
        user    = options.fetch(:user)
        pass    = options.fetch(:pass)
        host    = options.fetch(:host, "localhost")
        section = options.fetch(:section, '1')
        table_prefix = options.fetch(:prefix, "jos_")

        db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')

        FileUtils.mkdir_p("_posts")

        # Reads a MySQL database via Sequel and creates a post file for each
        # post in wp_posts that has post_status = 'publish'. This restriction is
        # made because 'draft' posts are not guaranteed to have valid dates.
        query = "SELECT `title`, `alias`, CONCAT(`introtext`,`fulltext`) as content, `created`, `id` FROM #{table_prefix}content WHERE state = '0' OR state = '1' AND sectionid = '#{section}'"

        db[query].each do |post|
          # Get required fields and construct Jekyll compatible name.
          title = post[:title]
          slug = post[:alias]
          date = post[:created]
          content = post[:content]
          name = "%02d-%02d-%02d-%s.markdown" % [date.year, date.month, date.day,
                                                 slug]

          # Get the relevant fields as a hash, delete empty fields and convert
          # to YAML for the header.
          data = {
             'layout' => 'post',
             'title' => title.to_s,
             'joomla_id' => post[:id],
             'joomla_url' => post[:alias],
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
