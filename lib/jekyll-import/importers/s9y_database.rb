# frozen_string_literal: false

module JekyllImport
  module Importers
    class S9YDatabase < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(
          %w(
            rubygems
            sequel
            fileutils
            safe_yaml
            unidecode
            nokogiri
          )
        )
      end

      def self.specify_options(c)
        c.option "dbname",            "--dbname DB",           "Database name. (default: '')"
        c.option "socket",            "--socket SOCKET",       "Database socket. (default: '')"
        c.option "user",              "--user USER",           "Database user name. (default: '')"
        c.option "password",          "--password PW",         "Database user's password. (default: '')"
        c.option "host",              "--host HOST",           "Database host name. (default: 'localhost')"
        c.option "port",              "--port PORT",           "Custom database port connect to. (default: 3306)"
        c.option "table_prefix",      "--table_prefix PREFIX", "Table prefix name. (default: 'serendipity_')"
        c.option "clean_entities",    "--clean_entities",      "Whether to clean entities. (default: true)"
        c.option "comments",          "--comments",            "Whether to import comments. (default: true)"
        c.option "categories",        "--categories",          "Whether to import categories. (default: true)"
        c.option "tags",              "--tags",                "Whether to import tags. (default: true)"
        c.option "drafts",            "--drafts",              "Whether to export drafts as well. (default: true)"
        c.option "markdown",          "--markdown",            "convert into markdown format. (default: false)"
        c.option "permalinks",        "--permalinks",          "preserve S9Y permalinks. (default: false)"
        c.option "excerpt_separator", "--excerpt_separator",   "Demarkation for excerpts. (default: '<a id=\"extended\"></a>')"
        c.option "includeentry",      "--includeentry",        "Replace macros from the includeentry plugin. (default: false)"
        c.option "imgfig",            "--imgfig",              "Replace nested img and youtube divs with HTML figure tags. (default: true)"
        c.option "linebreak",         "--linebreak",           "Line break processing: wp, nokogiri, ignore. (default: wp)"
        c.option "relative",          "--relative",            "Convert links with this prefix to relative. (default: nil)"
      end

      # Main migrator function. Call this to perform the migration.
      #
      # dbname::  The name of the database
      # user::    The database user name
      # pass::    The database user's password
      # host::    The address of the MySQL database host. Default: 'localhost'
      # port::    The port of the MySQL database server. Default: 3306
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
      #                   YAML front matter, in lowercase.  Default: true.
      # :extension::      Set the post extension. Default: "html"
      # :drafts::         If true, export drafts as well
      #                   Default: true.
      # :markdown::       If true, convert the content to markdown
      #                   Default: false
      # :permalinks::     If true, save the post's original permalink in its
      #                   YAML front matter. If the 'entryproperties' plugin
      #                   was used, its permalink will become the canonical
      #                   permalink, and any other will become redirects.
      #                   Default: false.
      # :excerpt_separator:: A string to use to separate the excerpt (body
      #                      in S9Y) from the rest of the article (extended
      #                      body in S9Y). Default: "<a id=\"extended\"></a>".
      # :includentry::    Replace macros from the includentry plugin - these are
      #                   the [s9y-include-entry] and [s9y-include-block] macros.
      #                   Default: false.
      # :imgfig::         Replace S9Y image-comment divs with an HTML figure
      #                   div and figcaption, if applicable. Works for img and
      #                   iframe.
      #                   Default: true.
      #
      # :linebreak::      When set to the default "wp", line breaks in entries
      #                   will be processed WordPress style, by replacing double
      #                   line breaks with HTML p tags, and remaining single
      #                   line breaks with HTML br tags. When set to "nokogiri",
      #                   entries will be loaded into Nokogiri and formatted as
      #                   an XHTML fragment. When set to "ignore", line breaks
      #                   will not be replaced at all.
      #                   Default: wp
      # :relative::       Replace absolute links (http://:relative:/foo)
      #                   to relative links (/foo).

      def self.process(opts)
        options = {
          :user              => opts.fetch("user", ""),
          :pass              => opts.fetch("password", ""),
          :host              => opts.fetch("host", "127.0.0.1"),
          :port              => opts.fetch("port", 3306),
          :socket            => opts.fetch("socket", nil),
          :dbname            => opts.fetch("dbname", ""),
          :table_prefix      => opts.fetch("table_prefix", "serendipity_"),
          :clean_entities    => opts.fetch("clean_entities", true),
          :comments          => opts.fetch("comments", true),
          :categories        => opts.fetch("categories", true),
          :tags              => opts.fetch("tags", true),
          :extension         => opts.fetch("extension", "html"),
          :drafts            => opts.fetch("drafts", true),
          :markdown          => opts.fetch("markdown", false),
          :permalinks        => opts.fetch("permalinks", false),
          :excerpt_separator => opts.fetch("excerpt_separator", "<a id=\"extended\"></a>"),
          :includeentry      => opts.fetch("includeentry", false),
          :imgfig            => opts.fetch("imgfig", true),
          :linebreak         => opts.fetch("linebreak", "wp"),
          :relative          => opts.fetch("relative", nil),
        }

        options[:clean_entities] = require_if_available("htmlentities", "clean_entities") if options[:clean_entities]
        options[:markdown] = require_if_available("reverse_markdown", "markdown") if options[:markdown]

        FileUtils.mkdir_p("_posts")
        FileUtils.mkdir_p("_drafts") if options[:drafts]

        db = Sequel.mysql2(options[:dbname],
                           :user     => options[:user],
                           :password => options[:pass],
                           :socket   => options[:socket],
                           :host     => options[:host],
                           :port     => options[:port],
                           :encoding => "utf8")

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
            :slug => page[:slug],
          }
        end

        posts_query = "
           SELECT
             'post'                 AS `type`,
             entries.ID             AS `id`,
             entries.isdraft        AS `isdraft`,
             entries.title          AS `title`,
             entries.timestamp      AS `timestamp`,
             entries.body           AS `body`,
             entries.extended       AS `body_extended`,
             authors.realname     AS `author`,
             authors.username     AS `author_login`,
             authors.email        AS `author_email`
           FROM #{px}entries AS `entries`
             LEFT JOIN #{px}authors AS `authors`
               ON entries.authorid = authors.authorid"

        posts_query << "WHERE posts.isdraft = 'false'" unless options[:drafts]

        db[posts_query].each do |post|
          process_post(post, db, options, page_name_list)
        end
      end

      def self.process_post(post, db, options, page_name_list)
        extension = options[:extension]

        title = post[:title]
        title = clean_entities(title) if options[:clean_entities]

        slug = post[:slug]
        slug = sluggify(title) if !slug || slug.empty?

        status = post[:isdraft] == "true" ? "draft" : "published"
        date = Time.at(post[:timestamp]).utc || Time.now.utc
        name = format("%02d-%02d-%02d-%s.%s", date.year, date.month, date.day, slug, extension)

        content = post[:body].to_s
        extended_content = post[:body_extended].to_s

        content += options[:excerpt_separator] + extended_content unless extended_content.nil? || extended_content.strip.empty?

        content = process_includeentry(content, db, options) if options[:includeentry]
        content = process_img_div(content) if options[:imgfig]
        content = clean_entities(content) if options[:clean_entities]
        content = content.gsub(%r!href=(["'])http://#{options[:relative]}!, 'href=\1') if options[:relative]

        content = ReverseMarkdown.convert(content) if options[:markdown]

        categories = process_categories(db, options, post)
        comments = process_comments(db, options, post)
        tags = process_tags(db, options, post)
        all_permalinks = process_permalink(db, options, post)
        primary_permalink = all_permalinks.shift
        supplemental_permalinks = all_permalinks unless all_permalinks.empty?

        # Get the relevant fields as a hash, delete empty fields and
        # convert to YAML for the header.
        data = {
          "layout"            => post[:type].to_s,
          "status"            => status.to_s,
          "published"         => status.to_s == "draft" ? nil : (status.to_s == "published"),
          "title"             => title.to_s,
          "author"            => post[:author].to_s,
          "author_login"      => post[:author_login].to_s,
          "author_email"      => post[:author_email].to_s,
          "date"              => date.to_s,
          "permalink"         => options[:permalinks] ? primary_permalink : nil,
          "redirect_from"     => options[:permalinks] ? supplemental_permalinks : nil,
          "categories"        => options[:categories] ? categories : nil,
          "tags"              => options[:tags] ? tags : nil,
          "comments"          => options[:comments] ? comments : nil,
          "excerpt_separator" => extended_content.empty? ? nil : options[:excerpt_separator],
        }.delete_if { |_k, v| v.nil? || v == "" }.to_yaml

        if post[:type] == "page"
          filename = page_path(post[:id], page_name_list) + "index.#{extension}"
          FileUtils.mkdir_p(File.dirname(filename))
        elsif status == "draft"
          filename = "_drafts/#{slug}.#{extension}"
        else
          filename = "_posts/#{name}"
        end

        content = case options[:linebreak]
                  when "nokogiri"
                    Nokogiri::HTML.fragment(content).to_xhtml
                  when "ignore"
                    content
                  else
                    # "wp" is the only remaining option, and the default
                    Util.wpautop(content)
                  end

        # Write out the data and content to file
        File.open(filename, "w") do |f|
          f.puts data
          f.puts "---"
          f.puts content
        end
      end

      def self.require_if_available(gem_name, option_name)
        require gem_name
        true
      rescue LoadError
        Jekyll.logger.warn "s9y database:", "Could not require '#{gem_name}', so the :#{option_name} option is now disabled."
        true
      end

      def self.process_includeentry(text, db, options)
        return text unless options[:includeentry]

        result = text

        px = options[:table_prefix]

        props  = text.scan(%r!(\[s9y-include-entry:([0-9]+):([^:]+)\])!)
        blocks = text.scan(%r!(\[s9y-include-block:([0-9]+):?([^:]+)?\])!)

        props.each do |match|
          macro = match[0]
          id = match[1]
          replacement = ""
          if match[2].start_with?("prop=")
            prop = match[2].sub("prop=", "")
            cquery = get_property_query(px, id, prop)
          else
            prop = match[2]
            cquery = get_value_query(px, id, prop)
          end
          db[cquery].each do |row|
            replacement << row[:txt]
          end
          result = result.sub(macro, replacement)
        end

        blocks.each do |match|
          macro = match[0]
          id = match[1]
          replacement = ""
          # match[2] *could* be 'template', but we can't run it through Smarty, so we ignore it
          cquery = %(
            SELECT
              px.body AS `txt`
            FROM
              #{px}staticblocks AS px
            WHERE
              id = '#{id}'
          )
          db[cquery].each do |row|
            replacement << row[:txt]
          end
          result = result.sub(macro, replacement)
        end

        result
      end

      def get_property_query(px, id, prop)
        %(
          SELECT
            px.value AS `txt`
          FROM
            #{px}entryproperties AS px
          WHERE
            entryid = '#{id}' AND
            property = '#{prop}'
        )
      end

      def get_value_query(px, id, prop)
        %(
          SELECT
            px.#{prop} AS `txt`
          FROM
            #{px}entries AS px
          WHERE
            entryid = '#{id}'
        )
      end

      # Replace .serendipity_imageComment_* blocks
      def self.process_img_div(text)
        caption_classes = [
          ".serendipity_imageComment_left",
          ".serendipity_imageComment_right",
          ".serendipity_imageComment_center",
        ]

        noko = Nokogiri::HTML.fragment(text)
        noko.css(caption_classes.join(",")).each do |imgcaption|
          block_attrs = get_block_attrs(imgcaption)

          # Is this a thumbnail to a bigger/other image?
          big_link = imgcaption.at_css(".serendipity_image_link")
          big_link ||= imgcaption.at_xpath(".//a[.//img]")

          # The caption (if any) may have raw HTML
          caption_elem = imgcaption.at_css(".serendipity_imageComment_txt")
          caption = ""
          caption = "<figcaption>#{caption_elem.inner_html}</figcaption>" if caption_elem

          image_node = imgcaption.at_css("img")
          if image_node
            attrs = get_media_attrs(image_node)
            media = "<img #{attrs}/>"
          else
            iframe_node = imgcaption.at_css("iframe")
            if iframe_node
              attrs = get_media_attrs(iframe_node)
              media = "<iframe #{attrs}'></iframe>"
            else
              Jekyll.logger.warn "s9y database:", "Unrecognized media block: #{imgcaption}"
              return text
            end
          end

          # Wrap media in link, if any
          if big_link
            big = big_link.attribute("href")
            media = "<a href='#{big}'>#{media}</a>"
          end

          # Replace HTML with clean media source, wrapped in figure
          imgcaption.replace("<figure #{block_attrs}#{media}#{caption}</figure>")
        end

        noko.to_s
      end

      def get_media_attrs(node)
        width = node.attribute("width")
        width = "width='#{width}'" if width
        height = node.attribute("height")
        height = "height='#{height}'" if height
        alt = node.attribute("alt")
        alt = "alt='#{alt}'" if alt
        src = "src='" + node.attribute("src") + "'"
        [src, width, height, alt].join(" ")
      end

      def get_block_attrs(imgcaption)
        # Extract block-level attributes
        float = imgcaption.attribute("class").value.sub("serendipity_imageComment_", "")
        float = "class='figure-#{float}'"
        style = imgcaption.attribute("style")
        style = " style='#{style.value}'" if style
        # Don't lose good data
        mdbnum = imgcaption.search(".//comment()").text.strip.sub("s9ymdb:", "")
        mdb = "<!-- mdb='#{mdbnum}' -->" if mdbnum
        [float, style, mdb].join(" ")
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
          categories << if options[:clean_entities]
                          clean_entities(category[:name])
                        else
                          category[:name]
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

          comcontent.force_encoding("UTF-8") if comcontent.respond_to?(:force_encoding)

          if options[:clean_entities]
            comcontent = clean_entities(comcontent)
            comauthor = clean_entities(comauthor)
          end

          comments << {
            "id"           => comment[:id].to_i,
            "author"       => comauthor,
            "author_email" => comment[:author_email].to_s,
            "author_url"   => comment[:author_url].to_s,
            "date"         => comment[:date].to_s,
            "content"      => comcontent,
          }
        end.sort! { |a, b| a["id"] <=> b["id"] }
      end

      def self.process_tags(db, options, post)
        return [] unless options[:tags]

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
          tags << if options[:clean_entities]
                    clean_entities(tag[:name]).downcase
                  else
                    tag[:name].downcase
                  end
        end
      end

      def self.process_permalink(db, options, post)
        return [] unless options[:permalinks]

        permalinks = []

        px = options[:table_prefix]

        if db.table_exists?("#{px}entryproperties")
          pquery = %(
            SELECT
              props.value AS `permalink`
            FROM
              #{px}entryproperties AS props
            WHERE
              props.entryid = '#{post[:id]}' AND
              props.property = 'permalink'
          )
          db[pquery].each do |link|
            plink = link[:permalink].to_s
            permalinks << plink unless plink.end_with? "/UNKNOWN.html"
          end
        end

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
          permalinks << "/#{link[:permalink]}"
        end

        permalinks
      end

      def self.clean_entities(text)
        text.force_encoding("UTF-8") if text.respond_to?(:force_encoding)
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

      def self.sluggify(title)
        title.to_ascii.downcase.gsub(%r![^0-9A-Za-z]+!, " ").strip.tr(" ", "-")
      end

      def self.page_path(page_id, page_name_list)
        if page_name_list.key?(page_id)
          [
            page_name_list[page_id][:slug],
            "/",
          ].join("")
        else
          ""
        end
      end
    end
  end
end
