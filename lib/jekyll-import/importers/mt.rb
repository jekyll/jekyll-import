module JekyllImport
  module Importers
    class MT < Importer

      SUPPORTED_ENGINES = %{mysql postgres sqlite}

      STATUS_DRAFT = 1
      STATUS_PUBLISHED = 2
      MORE_CONTENT_SEPARATOR = '<!--more-->'

      def self.default_options
        {
          'blog_id' => nil,
          'categories' => true,
          'dest_encoding' => 'utf-8',
          'src_encoding' => 'utf-8',
          'comments' => false
        }
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          sequel
          fileutils
          safe_yaml
        ])
      end

      def self.specify_options(c)
        c.option 'engine', "--engine ENGINE", "Database engine, (default: 'mysql', postgres also supported)"
        c.option 'dbname', '--dbname DB', 'Database name'
        c.option 'user', '--user USER', 'Database user name'
        c.option 'password', '--password PW', "Database user's password, (default: '')"
        c.option 'host', '--host HOST', 'Database host name (default: "localhost")'
        c.option 'port', '--port PORT', 'Custom database port connect to (optional)'
        c.option 'blog_id', '--blog_id ID', 'Specify a single Movable Type blog ID to import (default: all blogs)'
        c.option 'categories', '--categories', "If true, save post's categories in its YAML front matter. (default: true)"
        c.option 'src_encoding', '--src_encoding ENCODING', "Encoding of strings from database. (default: UTF-8)"
        c.option 'dest_encoding', '--dest_encoding ENCODING', "Encoding of output strings. (default: UTF-8)"
        c.option 'comments','--comments', "If true, output comments in _comments directory (default: false)"
      end

      # By default this migrator will include posts for all your MovableType blogs.
      # Specify a single blog by providing blog_id.

      # Main migrator function. Call this to perform the migration.
      #
      # dbname::  The name of the database
      # user::    The database user name
      # pass::    The database user's password
      # host::    The address of the MySQL database host. Default: 'localhost'
      # options:: A hash of configuration options
      #
      # Supported options are:
      #
      # blog_id::         Specify a single MovableType blog to export by providing blog_id.
      #                   Default: nil, importer will include posts for all blogs.
      # categories::      If true, save the post's categories in its
      #                   YAML front matter. Default: true
      # src_encoding::    Encoding of strings from the database. Default: UTF-8
      #                   If your output contains mangled characters, set src_encoding to
      #                   something appropriate for your database charset.
      # dest_encoding::   Encoding of output strings. Default: UTF-8
      # comments::        If true, output comments in _comments directory, like the one
      #                   mentioned at https://github.com/mpalmer/jekyll-static-comments/
      def self.process(options)
        options  = default_options.merge(options)

        comments = options.fetch('comments')
        posts_name_by_id = {} if comments

        db = database_from_opts(options)

        post_categories = db[:mt_placement].join(:mt_category, :category_id => :placement_category_id)

        FileUtils.mkdir_p "_posts"

        posts = db[:mt_entry]
        posts = posts.filter(:entry_blog_id => options['blog_id']) if options['blog_id']
        posts.each do |post|
          categories = post_categories.filter(
            :mt_placement__placement_entry_id => post[:entry_id]
          ).map {|ea| encode(ea[:category_basename], options) }

          file_name = post_file_name(post, options)

          data = post_metadata(post, options)
          data['categories'] = categories if !categories.empty? && options['categories']
          yaml_front_matter = data.delete_if { |_,v| v.nil? || v == '' }.to_yaml

          # save post path for comment processing
          posts_name_by_id[data['post_id']] = file_name if comments

          content = post_content(post, options)

          File.open("_posts/#{file_name}", "w") do |f|
            f.puts yaml_front_matter
            f.puts "---"
            f.puts encode(content, options)
          end
        end

        # process comment output, if enabled
        if comments
          FileUtils.mkdir_p "_comments"

          comments = db[:mt_comment]
          comments.each do |comment|
            if posts_name_by_id.key?(comment[:comment_entry_id]) # if the entry exists
              dir_name, base_name = comment_file_dir_and_base_name(posts_name_by_id, comment, options)
              FileUtils.mkdir_p "_comments/#{dir_name}"

              data = comment_metadata(comment, options)
              content = comment_content(comment, options)
              yaml_front_matter = data.delete_if { |_,v| v.nil? || v == '' }.to_yaml

              File.open("_comments/#{dir_name}/#{base_name}", "w") do |f|
                f.puts yaml_front_matter
                f.puts "---"
                f.puts encode(content, options)
              end
            end
          end
        end

      end

      # Extracts metadata for YAML front matter from post
      def self.post_metadata(post, options = default_options)
        metadata = {
          'layout' => 'post',
          'title' => encode(post[:entry_title], options),
          'date' => post_date(post).strftime("%Y-%m-%d %H:%M:%S %z"),
          'excerpt' => encode(post[:entry_excerpt].to_s, options),
          'mt_id' => post[:entry_id],
          'blog_id' => post[:entry_blog_id],
          'post_id' => post[:entry_id], # for link with comments
          'basename' => post[:entry_basename]
        }
        metadata['published'] = false if post[:entry_status] != STATUS_PUBLISHED
        metadata
      end

      # Different versions of MT used different column names
      def self.post_date(post)
        post[:entry_authored_on] || post[:entry_created_on]
      end

      # Extracts text body from post
      def self.extra_entry_text_empty?(post)
        post[:entry_text_more].nil? || post[:entry_text_more].strip.empty?
      end

      def self.post_content(post, options = default_options)
        if extra_entry_text_empty?(post)
          post[:entry_text]
        else
          post[:entry_text] + "\n\n#{MORE_CONTENT_SEPARATOR}\n\n" + post[:entry_text_more]
        end
      end

      def self.post_file_name(post, options = default_options)
        date = post_date(post)
        slug = post[:entry_basename]
        file_ext = suffix(post[:entry_convert_breaks])

        "#{date.strftime('%Y-%m-%d')}-#{slug}.#{file_ext}"
      end

      # Extracts metadata for YAML front matter from comment
      def self.comment_metadata(comment, options = default_options)
        metadata = {
          'layout' => 'comment',
          'comment_id' => comment[:comment_id],
          'post_id' => comment[:comment_entry_id],
          'author' => encode(comment[:comment_author], options),
          'email' => comment[:comment_email],
          'commenter_id' => comment[:comment_commenter_id],
          'date' => comment_date(comment).strftime("%Y-%m-%d %H:%M:%S %z"),
          'visible' => comment[:comment_visible] == 1,
          'ip' => comment[:comment_ip],
          'url' => comment[:comment_url]
        }
        metadata
      end

      # Different versions of MT used different column names
      def self.comment_date(comment)
        comment[:comment_modified_on] || comment[:comment_created_on]
      end

      def self.comment_content(comment, options = default_options)
        comment[:comment_text]
      end

      def self.comment_file_dir_and_base_name(posts_name_by_id, comment, options = default_options)
        post_basename = posts_name_by_id[comment[:comment_entry_id]].sub(/\.\w+$/, '')
        comment_id = comment[:comment_id]

        [post_basename, "#{comment_id}.markdown"]
      end

      def self.encode(str, options = default_options)
        if str.respond_to?(:encoding)
          str.encode(options['dest_encoding'], options['src_encoding'])
        else
          str
        end
      end

      # Ideally, this script would determine the post format (markdown,
      # html, etc) and create files with proper extensions. At this point
      # it just assumes that markdown will be acceptable.
      def self.suffix(entry_type)
        if entry_type.nil? || entry_type.include?("markdown") || entry_type.include?("__default__")
          # The markdown plugin I have saves this as
          # "markdown_with_smarty_pants", so I just look for "markdown".
          "markdown"
        elsif entry_type.include?("textile")
          # This is saved as "textile_2" on my installation of MT 5.1.
          "textile"
        elsif entry_type == "0" || entry_type.include?("richtext")
          # Richtext looks to me like it's saved as HTML, so I include it here.
          "html"
        else
          # Other values might need custom work.
          entry_type
        end
      end

      def self.database_from_opts(options)
        engine   = options.fetch('engine', 'mysql')
        dbname   = options.fetch('dbname')

        case engine
        when "sqlite"
          Sequel.sqlite(dbname)
        when "mysql", "postgres"
          db_connect_opts = {
            :host =>     options.fetch('host', 'localhost'),
            :user =>     options.fetch('user'),
            :password => options.fetch('password', '')
          }
          db_connect_opts = options['port'] if options['port']
          Sequel.public_send(
            engine,
            dbname,
            db_connect_opts
          )
        else
          abort("Unsupported engine: '#{engine}'. Must be one of #{SUPPORTED_ENGINES.join(', ')}")
        end
      end
    end
  end
end
