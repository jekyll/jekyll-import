# Created by Nick Gerakines, open source and publically available under the
# MIT license. Use this module at your own risk.
# I'm an Erlang/Perl/C++ guy so please forgive my dirty ruby.

# NOTE: This converter requires Sequel and the MySQL gems.
# The MySQL gem can be difficult to install on OS X. Once you have MySQL
# installed, running the following commands should work:
# $ sudo gem install sequel
# $ sudo gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config

module JekyllImport
  module Importers
    class MT < Importer

      STATUS_DRAFT = 1
      STATUS_PUBLISHED = 2
      MORE_CONTENT_SEPARATOR = '<!--more-->'

      def self.default_options
        {
          :blog_id => nil,
          :categories => true,
          :dest_encoding => 'utf-8',
          :src_encoding => 'utf-8'
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
      # :blog_id::        Specify a single MovableType blog to export by providing blog_id.
      #                   Default: nil, importer will include posts for all blogs.
      # :categories::     If true, save the post's categories in its
      #                   YAML front matter. Default: true
      # :src_encoding::   Encoding of strings from the database. Default: UTF-8
      #                   If your output contains mangled characters, set src_encoding to
      #                   something appropriate for your database charset.
      # :dest_encoding::  Encoding of output strings. Default: UTF-8
      def self.process(options)
        dbname = options.fetch(:dbname)
        user   = options.fetch(:user)
        pass   = options.fetch(:pass)
        host   = options.fetch(:host, "localhost")

        options = default_options.merge(options)

        db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host)
        post_categories = db[:mt_placement].join(:mt_category, :category_id => :placement_category_id)

        FileUtils.mkdir_p "_posts"

        posts = db[:mt_entry]
        posts = posts.filter(:entry_blog_id => options[:blog_id]) if options[:blog_id]
        posts.each do |post|
          categories = post_categories.filter(
            :mt_placement__placement_entry_id => post[:entry_id]
          ).map {|ea| encode(ea[:category_basename], options) }

          file_name = post_file_name(post, options)

          data = post_metadata(post, options)
          data['categories'] = categories if !categories.empty? && options[:categories]
          yaml_front_matter = data.delete_if { |k,v| v.nil? || v == '' }.to_yaml

          content = post_content(post, options)

          File.open("_posts/#{file_name}", "w") do |f|
            f.puts yaml_front_matter
            f.puts "---"
            f.puts encode(content, options)
          end
        end
      end

      # Extracts metadata for YAML front matter from post
      def self.post_metadata(post, options = default_options)
        metadata = {
          'layout' => 'post',
          'title' => encode(post[:entry_title], options),
          'date' => post_date(post).strftime("%Y-%m-%d %H:%M:%S %z"),
          'excerpt' => encode(post[:entry_excerpt], options),
          'mt_id' => post[:entry_id]
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

      def self.encode(str, options = default_options)
        if str.respond_to?(:encoding)
          str.encode(options[:dest_encoding], options[:src_encoding])
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
    end
  end
end
