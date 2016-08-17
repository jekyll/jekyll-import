module JekyllImport
  module Importers
    class Joomla3 < Importer
      def self.validate(options)
        %w[dbname user prefix].each do |option|
          if options[option].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.specify_options(c)
        c.option 'dbname', '--dbname', 'Database name'
        c.option 'user', '--user', 'Database user name'
        c.option 'password', '--password', "Database user's password (default: '')"
        c.option 'host', '--host', 'Database host name'
        c.option 'category', '--category', 'ID of the category'
        c.option 'prefix', '--prefix', 'Table prefix name'
        c.option 'state', '--state', 'Which publishing state to select. 0: unpublished, 1: published, 2: archived (default: 1)'
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
        dbname  = options.fetch('dbname')
        user    = options.fetch('user')
        pass    = options.fetch('password', '')
        host    = options.fetch('host', "localhost")
        cid	    = options.fetch('category', 0)
        table_prefix = options.fetch('prefix', "jos_")
        state   = options.fetch('state', 1)

        db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')

        if state == 0
          directory = "_drafts"
        else
          directory = "_posts"
        end
        FileUtils.mkdir_p(directory)

        # Reads a MySQL database via Sequel and creates a post file for each
        # post in #__content that is published.
        query = "SELECT `cn`.`title`, `cn`.`alias`, `cn`.`introtext`, CONCAT(`cn`.`introtext`,`cn`.`fulltext`) AS `content`, "
		query << "`cn`.`created`, `cn`.`id`, `ct`.`title` AS `category`, `u`.`name` AS `author` "
		query << "FROM `#{table_prefix}content` AS `cn` JOIN `#{table_prefix}categories` AS `ct` ON `cn`.`catid` = `ct`.`id` "
		query << "JOIN `#{table_prefix}users` AS `u` ON `cn`.`created_by` = `u`.`id` "
		query << "WHERE `cn`.`state` = '#{state}' "

		if cid > 0
			query << " AND `cn`.`catid` = '#{cid}' "
		else 
			query << " AND `cn`.`catid` != '2' " #Filter out uncategorized content
		end

        db[query].each do |post|
          # Get required fields and construct Jekyll compatible name.
          title = post[:title]
          slug = post[:alias]
          date = post[:created]
          author = post[:author]
          category = post[:category]
          content = post[:content]
          excerpt = post[:introtext]
          if state == 0
            name = "%s.markdown" % [slug]
          else
            name = "%02d-%02d-%02d-%s.markdown" % [date.year, date.month, date.day,
                                                   slug]
          end

          # Get the relevant fields as a hash, delete empty fields and convert
          # to YAML for the header.
          data = {
             'layout' => 'post',
             'title' => title.to_s,
             'joomla_id' => post[:id],
             'joomla_url' => slug,
             'date' => date,
             'author' => author,
             'excerpt' => excerpt.strip.to_s,
             'category' => category
           }.delete_if { |k,v| v.nil? || v == '' }.to_yaml

          # Write out the data and content to file
          File.open("#{directory}/#{name}", "w") do |f|
            f.puts data
            f.puts "---"
            f.puts content
          end
        end
      end
    end
  end
end
