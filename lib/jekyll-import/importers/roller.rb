# frozen_string_literal: true

module JekyllImport
  module Importers
    class Roller < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          rubygems
          sequel
          fileutils
          safe_yaml
          unidecode
        ))
      end

      def self.specify_options(c)
        c.option "dbname",         "--dbname DB",      "Database name (default: '')"
        c.option "socket",         "--socket SOCKET",  "Database socket (default: '')"
        c.option "user",           "--user USER",      "Database user name (default: '')"
        c.option "password",       "--password PW",    "Database user's password (default: '')"
        c.option "host",           "--host HOST",      "Database host name (default: 'localhost')"
        c.option "port",           "--port PORT",      "Database port number (default: '3306')"
        c.option "clean_entities", "--clean_entities", "Whether to clean entities (default: true)"
        c.option "comments",       "--comments",       "Whether to import comments (default: true)"
        c.option "categories",     "--categories",     "Whether to import categories (default: true)"
        c.option "tags",           "--tags",           "Whether to import tags (default: true)"

        c.option "status",         "--status STATUS,STATUS2", Array,
                 "Array of allowed statuses (default: ['PUBLISHED'], other options: 'DRAFT')"
      end

      # Main migrator function. Call this to perform the migration.
      #
      # dbname::  The name of the database
      # user::    The database user name
      # pass::    The database user's password
      # host::    The address of the MySQL database host. Default: 'localhost'
      # port::    The port number of the MySQL database. Default: '3306'
      # socket::  The database socket's path
      # options:: A hash table of configuration options.
      #
      # Supported options are:
      #
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
      # :status::         Array of allowed post statuses. Only
      #                   posts with matching status will be migrated.
      #                   Known statuses are :PUBLISHED and :DRAFT
      #                   If this is nil or an empty
      #                   array, all posts are migrated regardless of
      #                   status. Default: [:PUBLISHED].
      #
      def self.process(opts)
        options = {
          :user           => opts.fetch("user", ""),
          :pass           => opts.fetch("password", ""),
          :host           => opts.fetch("host", "localhost"),
          :port           => opts.fetch("port", "3306"),
          :socket         => opts.fetch("socket", nil),
          :dbname         => opts.fetch("dbname", ""),
          :clean_entities => opts.fetch("clean_entities", true),
          :comments       => opts.fetch("comments", true),
          :categories     => opts.fetch("categories", true),
          :tags           => opts.fetch("tags", true),
          :extension      => opts.fetch("extension", "html"),
          :status         => opts.fetch("status", ["PUBLISHED"]).map(&:to_sym) # :DRAFT
        }

        if options[:clean_entities]
          begin
            require "htmlentities"
          rescue LoadError
            STDERR.puts "Could not require 'htmlentities', so the :clean_entities option is now disabled."
            options[:clean_entities] = false
          end
        end

        FileUtils.mkdir_p("_posts")
        FileUtils.mkdir_p("_drafts") if options[:status].include? :DRAFT

        db = Sequel.mysql2(options[:dbname],
                           :user     => options[:user],
                           :password => options[:pass],
                           :socket   => options[:socket],
                           :host     => options[:host],
                           :port     => options[:port],
                           :encoding => "utf8")

        select = ["weblogentry.id AS `id`",
                  "weblogentry.status AS `status`",
                  "weblogentry.title AS `title`",
                  "weblogentry.anchor AS `slug`",
                  "weblogentry.updatetime AS `date`",
                  "weblogentry.text AS `content`",
                  "weblogentry.summary AS `excerpt`",
                  "weblogentry.categoryid AS `categoryid`",
                  "roller_user.fullname AS `author`",
                  "roller_user.username AS `author_login`",
                  "roller_user.emailaddress AS `author_email`",
                  "weblog.handle AS `site`",]
        table = "weblogentry AS `weblogentry`"
        join = ["roller_user AS `roller_user` ON weblogentry.creator = roller_user.username",
                "weblog AS `weblog` ON weblogentry.websiteid = weblog.id",]
        condition = []

        if options[:status] && !options[:status].empty?
          options[:status].each do |stat|
            condition.push("weblogentry.status = '#{stat}'")
          end
        end

        posts_query = gen_db_query(select, table, condition, join, "OR")
        db[posts_query].each do |post|
          process_post(post, db, options)
        end
      end

      def self.process_post(post, db, options)
        extension = options[:extension]

        title = post[:title]
        title = clean_entities(title) if options[:clean_entities]

        slug = post[:slug]
        slug = sluggify(title) if !slug || slug.empty?

        date = post[:date] || Time.now
        name = format("%02d-%02d-%02d-%s.%s", date.year, date.month, date.day, slug, extension)

        content = post[:content].to_s
        content = clean_entities(content) if options[:clean_entities]

        excerpt = post[:excerpt].to_s

        permalink = "#{post[:site]}/entry/#{post[:slug]}"

        categories = []
        tags       = []

        if options[:categories]
          select = "weblogcategory.name AS `name`"
          table = "weblogcategory AS `weblogcategory`"
          condition = "weblogcategory.id = '#{post[:categoryid]}'"
          cquery = gen_db_query(select, table, condition, "", "")

          db[cquery].each do |term|
            categories << (options[:clean_entities] ? clean_entities(term[:name]) : term[:name])
          end
        end

        if options[:tags]
          select = "roller_weblogentrytag.name AS `name`"
          table = "roller_weblogentrytag AS `roller_weblogentrytag`"
          condition = "roller_weblogentrytag.entryid = '#{post[:id]}'"
          cquery = gen_db_query(select, table, condition, "", "")

          db[cquery].each do |term|
            tags << (options[:clean_entities] ? clean_entities(term[:name]) : term[:name])
          end
        end

        comments = []

        if options[:comments]
          select = ["id AS `id`",
                    "name AS `author`",
                    "email AS `author_email`",
                    "url AS `author_url`",
                    "posttime AS `date`",
                    "content AS `content`",]
          condition = ["entryid = '#{post[:id]}'", "status = 'APPROVED'"]
          cquery = gen_db_query(select, "roller_comment", condition, "", "AND")

          db[cquery].each do |comment|
            comcontent = comment[:content].to_s
            comauthor  = comment[:author].to_s
            comcontent.force_encoding("UTF-8") if comcontent.respond_to?(:force_encoding)

            if options[:clean_entities]
              comcontent = clean_entities(comcontent)
              comauthor  = clean_entities(comauthor)
            end

            comments << {
              "id"           => comment[:id].to_i,
              "author"       => comauthor,
              "author_email" => comment[:author_email].to_s,
              "author_url"   => comment[:author_url].to_s,
              "date"         => comment[:date].to_s,
              "content"      => comcontent,
            }
          end

          comments.sort! { |a, b| a["id"] <=> b["id"] }
        end

        # Get the relevant fields as a hash, delete empty fields and
        # convert to YAML for the header.
        data = {
          "layout"       => "post",
          "status"       => post[:status].to_s,
          "published"    => post[:status].to_s == "DRAFT" ? nil : (post[:status].to_s == "PUBLISHED"),
          "title"        => title.to_s,
          "author"       => {
            "display_name" => post[:author].to_s,
            "login"        => post[:author_login].to_s,
            "email"        => post[:author_email].to_s,
          },
          "author_login" => post[:author_login].to_s,
          "author_email" => post[:author_email].to_s,
          "excerpt"      => excerpt,
          "id"           => post[:id],
          "date"         => date.to_s,
          "categories"   => options[:categories] ? categories : nil,
          "tags"         => options[:tags] ? tags : nil,
          "comments"     => options[:comments] ? comments : nil,
          "permalink"    => permalink,
        }.delete_if { |_k, v| v.nil? || v == "" }.to_yaml

        filename = post[:status] == "DRAFT" ? "_drafts/#{slug}.md" : "_posts/#{name}"

        # Write out the data and content to file
        File.open(filename, "w") do |f|
          f.puts data
          f.puts "---"
          f.puts Util.wpautop(content)
        end
      end

      def self.clean_entities(text)
        text.force_encoding("UTF-8") if text.respond_to?(:force_encoding)
        text = HTMLEntities.new.encode(text, :named)
        # We don't want to convert these, it would break all
        # HTML tags in the post and comments.
        text.gsub!("&amp;",  "&")
        text.gsub!("&lt;",   "<")
        text.gsub!("&gt;",   ">")
        text.gsub!("&quot;", '"')
        text.gsub!("&apos;", "'")
        text.gsub!("&#47;",  "/")
        text
      end

      def self.sluggify(title)
        title.to_ascii.downcase.gsub(%r![^0-9a-z]+!, " ").strip.tr(" ", "-")
      end

      def self.page_path(_page_id)
        ""
      end

      def self.gen_db_query(select, table, condition, join, condition_join)
        condition_join_string = if condition_join.empty?
                                  "AND"
                                else
                                  condition_join
                                end
        select_string = if select.is_a?(Array)
                          select.join(",")
                        else
                          select
                        end
        condition_string = if condition.is_a?(Array)
                             condition.join(" #{condition_join_string} ")
                           else
                             condition
                           end
        join_string = if join.is_a?(Array)
                        join.join(" LEFT JOIN ")
                      else
                        join
                      end
        query_select = "SELECT #{select_string}"
        table_string = " FROM #{table}"
        query_join = if join_string.empty?
                       ""
                     else
                       " LEFT JOIN #{join_string}"
                     end
        query_condition = if condition_string.empty?
                            ""
                          else
                            " WHERE #{condition_string}"
                          end
        query = "#{query_select}#{table_string}#{query_join}#{query_condition}"
        query
      end
    end
  end
end
