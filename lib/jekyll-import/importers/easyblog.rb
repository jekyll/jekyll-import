module JekyllImport
  module Importers
    class Easyblog < Importer
      def self.validate(options)
        %w[dbname user].each do |option|
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
        c.option 'section', '--section', 'Table prefix name'
        c.option 'prefix', '--prefix', 'Table prefix name'
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
        section = options.fetch('section', '1')
        table_prefix = options.fetch('prefix', "jos_")

        db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')

        FileUtils.mkdir_p("_posts")

        # Reads a MySQL database via Sequel and creates a post file for each
        # post in wp_posts that has post_status = 'publish'. This restriction is
        # made because 'draft' posts are not guaranteed to have valid dates.

        query = "
        select
	  ep.`title`, `permalink` as alias, concat(`intro`, `content`) as content, ep.`created`, ep.`id`, ec.`title` as category, tags
        from
          #{table_prefix}easyblog_post ep
          left join #{table_prefix}easyblog_category ec on (ep.category_id = ec.id)
          left join (
            select
              ept.post_id,
              group_concat(et.alias order by alias separator ' ') as tags
            from
              #{table_prefix}easyblog_post_tag ept
              join #{table_prefix}easyblog_tag et on (ept.tag_id = et.id)
            group by
              ept.post_id) x on (ep.id = x.post_id);
        "

        db[query].each do |post|
          # Get required fields and construct Jekyll compatible name.
          title = post[:title]
          slug = post[:alias]
          date = post[:created]
          content = post[:content]
          category = post[:category]
          tags = post[:tags]
          name = "%02d-%02d-%02d-%s.markdown" % [date.year, date.month, date.day,
                                                 slug]

          # Get the relevant fields as a hash, delete empty fields and convert
          # to YAML for the header.
          data = {
            'layout' => 'post',
            'title' => title.to_s,
            'joomla_id' => post[:id],
            'joomla_url' => post[:alias],
            'category' => post[:category],
            'tags' => post[:tags],
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
