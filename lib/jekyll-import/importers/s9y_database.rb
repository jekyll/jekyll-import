module JekyllImport
  module Importers
    class S9YDatabase < Importer

      def self.require_deps
        JekyllImport.require_with_fallback(
          %w[
          rubygems
          sequel
          fileutils
          safe_yaml
          unidecode
          ])
      end

      def self.specify_options(c)
        c.option 'dbname', '--dbname DB', 'Database name (default: "")'
        c.option 'socket', '--socket SOCKET', 'Database socket (default: "")'
        c.option 'user', '--user USER', 'Database user name (default: "")'
        c.option 'password', '--password PW', "Database user's password (default: "")"
        c.option 'host', '--host HOST', 'Database host name (default: "localhost")'
        c.option 'table_prefix', '--table_prefix PREFIX', 'Table prefix name (default: "serendipity_")'
        c.option 'clean_entities', '--clean_entities', 'Whether to clean entities (default: true)'
        c.option 'comments', '--comments', 'Whether to import comments (default: true)'
        c.option 'categories', '--categories', 'Whether to import categories (default: true)'
        c.option 'tags', '--tags', 'Whether to import tags (default: true)'
        c.option 'drafts', '--drafts', 'Whether to export drafts as well'
        c.option 'markdown', '--markdown', 'convert into markdown format (default: false)'
        c.option 'permalinks', '--permalinks', 'preserve S9Y permalinks (default: false)'
      end

      # Main migrator function. Call this to perform the migration.
      #
      # dbname::  The name of the database
      # user::    The database user name
      # pass::    The database user's password
      # host::    The address of the MySQL database host. Default: 'localhost'
      # socket::  The database socket's path
      # options:: A hash table of configuration options.
      #
      # Supported options are:
      #
      # :table_prefix::   Prefix of database tables used by WordPress.
      #                   Default: 'serendipity_'
      # :clean_entities:: If true, convert non-ASCII characters to HTML
      #                   entities in the posts, comments, titles, and
      #                   names. Requires the 'htmlentities' gem to
      #                   work. Default: true.
      # :comments::       If true, migrate post comments too. Comments
      #                   are saved in the post's YAML front matter.
      #                   Default: true.
      # :categories::     If true, save the post's categories in its
      #                   YAML front matter. Default: true.
      # :tags::           If true, save the post's tags in its
      #                   YAML front matter. Default: true.
      # :extension::      Set the post extension. Default: "html"
      # :drafts::  If true, export drafts as well
      #                   Default: true.
      # :markdown::       If true, convert the content to markdown
      #                   Default: false
      # :permalinks::     If true, save the post's original permalink in its
      #                   YAML front matter. Default: false.
      #
      def self.process(opts)
        options = {
          :user           => opts.fetch('user', ''),
          :pass           => opts.fetch('password', ''),
          :host           => opts.fetch('host', 'localhost'),
          :socket         => opts.fetch('socket', nil),
          :dbname         => opts.fetch('dbname', ''),
          :table_prefix   => opts.fetch('table_prefix', 'serendipity_'),
          :clean_entities => opts.fetch('clean_entities', true),
          :comments       => opts.fetch('comments', true),
          :categories     => opts.fetch('categories', true),
          :tags           => opts.fetch('tags', true),
          :extension      => opts.fetch('extension', 'html'),
          :drafts         => opts.fetch('drafts', true),
          :markdown       => opts.fetch('markdown', false),
          :permalinks     => opts.fetch('permalinks', false),
        }

        if options[:clean_entities]
          options[:clean_entities] = require_if_available('htmlentities', 'clean_entities')
        end

        if options[:markdown]
          options[:markdown] = require_if_available('reverse_markdown', 'markdown')
        end

        FileUtils.mkdir_p("_posts")
        FileUtils.mkdir_p("_drafts") if options[:drafts]

        db = Sequel.mysql2(options[:dbname], :user => options[:user], :password => options[:pass],
                           :socket => options[:socket], :host => options[:host], :encoding => 'utf8')

        px = options[:table_prefix]

        page_name_list = {}

        page_name_query = %(
           SELECT
             entries.ID             AS `id`,
             entries.title          AS `title`
           FROM #{px}entries AS `entries`
        )

        db[page_name_query].each do |page|
          page[:slug] = sluggify(page[:title])

          page_name_list[ page[:id] ] = {
            :slug   => page[:slug]
          }
        end

        posts_query = "
           SELECT
             entries.ID             AS `id`,
             entries.isdraft        AS `isdraft`,
             entries.title          AS `title`,
             entries.timestamp      AS `timestamp`,
             entries.body           AS `body`,
             authors.realname     AS `author`,
             authors.username     AS `author_login`,
             authors.email        AS `author_email`
           FROM #{px}entries AS `entries`
             LEFT JOIN #{px}authors AS `authors`
               ON entries.authorid = authors.authorid"

        unless options[:drafts]
          posts_query << "WHERE posts.isdraft = 'false'"
        end

        db[posts_query].each do |post|
          process_post(post, db, options, page_name_list)
        end
      end

      def self.process_post(post, db, options, page_name_list)
        extension = options[:extension]

        title = post[:title]
        if options[:clean_entities]
          title = clean_entities(title)
        end

        slug = post[:slug]
        if !slug || slug.empty?
          slug = sluggify(title)
        end

        status = post[:isdraft] == 'true' ? 'draft' : 'published'
        date = Time.at(post[:timestamp]).utc || Time.now.utc
        name = "%02d-%02d-%02d-%s.%s" % [date.year, date.month, date.day, slug, extension]

        content = post[:body].to_s

        if options[:clean_entities]
          content = clean_entities(content)
        end

        if options[:markdown]
          content = ReverseMarkdown.convert(content)
        end

        categories = process_categories(db, options, post)
        comments = process_comments(db, options, post)
        tags = process_tags(db, options, post)
        permalink = process_permalink(db, options, post)

        # Get the relevant fields as a hash, delete empty fields and
        # convert to YAML for the header.
        data = {
          'layout'        => post[:type].to_s,
          'status'        => status.to_s,
          'published'     => status.to_s == 'draft' ? nil : (status.to_s == 'published'),
          'title'         => title.to_s,
          'author'        => {
            'display_name'=> post[:author].to_s,
            'login'       => post[:author_login].to_s,
            'email'       => post[:author_email].to_s
          },
          'author_login'  => post[:author_login].to_s,
          'author_email'  => post[:author_email].to_s,
          'date'          => date.to_s,
          'permalink'     => options[:permalinks] ? permalink : nil,
          'categories'    => options[:categories] ? categories : nil,
          'tags'          => options[:tags] ? tags : nil,
          'comments'      => options[:comments] ? comments : nil,
        }.delete_if { |k,v| v.nil? || v == '' }.to_yaml

        if post[:type] == 'page'
          filename = page_path(post[:id], page_name_list) + "index.#{extension}"
          FileUtils.mkdir_p(File.dirname(filename))
        elsif status == 'draft'
          filename = "_drafts/#{slug}.#{extension}"
        else
          filename = "_posts/#{name}"
        end

        # Write out the data and content to file
        File.open(filename, "w") do |f|
          f.puts data
          f.puts "---"
          f.puts Util.wpautop(content)
        end
      end

      def self.require_if_available(gem_name, option_name)
        begin
          require gem_name
          return true
        rescue LoadError
          STDERR.puts "Could not require '#{gem_name}', so the :#{option_name} option is now disabled."
          return true
        end
      end

      def self.process_categories(db, options, post)
        return [] unless options[:categories]

        px = options[:table_prefix]

        cquery = %(
            SELECT
               categories.category_name AS `name`
             FROM
              #{px}entrycat AS `entrycat`,
              #{px}category AS `categories`
             WHERE
               entrycat.entryid = '#{post[:id]}' AND
               entrycat.categoryid = categories.categoryid
        )

        db[cquery].each_with_object([]) do |category, categories|
          if options[:clean_entities]
            categories << clean_entities(category[:name])
          else
            categories << category[:name]
          end
        end
      end

      def self.process_comments(db, options, post)
        return [] unless options[:comments]

        px = options[:table_prefix]

        cquery = %(
            SELECT
               id           AS `id`,
               author       AS `author`,
               email        AS `author_email`,
               url          AS `author_url`,
               timestamp    AS `date`,
               body         AS `content`
             FROM #{px}comments
             WHERE
               entry_id = '#{post[:id]}' AND
               status = 'approved'
        )

        db[cquery].each_with_object([]) do |comment, comments|
          comcontent = comment[:content].to_s
          comauthor = comment[:author].to_s

          if comcontent.respond_to?(:force_encoding)
            comcontent.force_encoding("UTF-8")
          end

          if options[:clean_entities]
            comcontent = clean_entities(comcontent)
            comauthor = clean_entities(comauthor)
          end

          comments << {
            'id'           => comment[:id].to_i,
            'author'       => comauthor,
            'author_email' => comment[:author_email].to_s,
            'author_url'   => comment[:author_url].to_s,
            'date'         => comment[:date].to_s,
            'content'      => comcontent,
          }
        end.sort!{ |a,b| a['id'] <=> b['id'] }
      end

      def self.process_tags(db, options, post)
        return [] unless options[:categories]

        px = options[:table_prefix]

        cquery = %(
            SELECT
               entrytags.tag AS `name`
             FROM
              #{px}entrytags AS `entrytags`
             WHERE
               entrytags.entryid = '#{post[:id]}'
        )

        db[cquery].each_with_object([]) do |tag, tags|
          if options[:clean_entities]
            tags << clean_entities(tag[:name])
          else
            tags << tag[:name]
          end
        end
      end

      def self.process_permalink(db, options, post)
        return unless options[:permalinks]

        px = options[:table_prefix]

        cquery = %(
            SELECT
               permalinks.permalink AS `permalink`
             FROM
        #{px}permalinks AS `permalinks`
             WHERE
               permalinks.entry_id = '#{post[:id]}' AND
               permalinks.type = 'entry'
        )

        db[cquery].each do |link|
          return "/#{link[:permalink]}"
        end
      end

      def self.clean_entities( text )
        if text.respond_to?(:force_encoding)
          text.force_encoding("UTF-8")
        end
        text = HTMLEntities.new.encode(text, :named)
        # We don't want to convert these, it would break all
        # HTML tags in the post and comments.
        text.gsub!("&amp;", "&")
        text.gsub!("&lt;", "<")
        text.gsub!("&gt;", ">")
        text.gsub!("&quot;", '"')
        text.gsub!("&apos;", "'")
        text.gsub!("/", "&#47;")
        text
      end

      def self.sluggify( title )
        title.to_ascii.downcase.gsub(/[^0-9A-Za-z]+/, " ").strip.gsub(" ", "-")
      end

      def self.page_path( page_id, page_name_list )
        if page_name_list.key?(page_id)
          [
            page_name_list[page_id][:slug],
            '/'
          ].join("")
        else
          ""
        end
      end

    end
  end
end

