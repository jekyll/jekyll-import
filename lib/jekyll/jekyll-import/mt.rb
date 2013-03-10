# Created by Nick Gerakines, open source and publically available under the
# MIT license. Use this module at your own risk.
# I'm an Erlang/Perl/C++ guy so please forgive my dirty ruby.

require 'rubygems'
require 'sequel'
require 'fileutils'
require 'safe_yaml'

# NOTE: This converter requires Sequel and the MySQL gems.
# The MySQL gem can be difficult to install on OS X. Once you have MySQL
# installed, running the following commands should work:
# $ sudo gem install sequel
# $ sudo gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config

module JekyllImport
  module MT

    STATUS_DRAFT = 1
    STATUS_PUBLISHED = 2
    MORE_CONTENT_SEPARATOR = '<!--more-->'

    def self.default_options
      {
        :blog_id => nil
      }
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
    def self.process(dbname, user, pass, host = 'localhost', options = {})
      options = default_options.merge(options)

      db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')

      FileUtils.mkdir_p "_posts"

      posts = db[:mt_entry]
      posts = posts.filter(:entry_blog_id => options[:blog_id]) if options[:blog_id]
      posts.each do |post|
        title = post[:entry_title]
        slug = post[:entry_basename]
        date = post[:entry_authored_on]
        status = post[:entry_status]
        content = post[:entry_text]
        more_content = post[:entry_text_more]
        excerpt = post[:entry_excerpt]
        entry_convert_breaks = post[:entry_convert_breaks]

        # Be sure to include the body and extended body.
        unless more_content.strip.empty?
          content += "\n\n#{MORE_CONTENT_SEPARATOR}\n\n" + more_content
        end

        # Ideally, this script would determine the post format (markdown,
        # html, etc) and create files with proper extensions. At this point
        # it just assumes that markdown will be acceptable.
        name = [date.strftime("%Y-%m-%d"), slug].join('-') + '.' +
          self.suffix(entry_convert_breaks)

        data = {
          'layout' => 'post',
          'title' => title.to_s,
          'mt_id' => post[:entry_id],
          'date' => date.strftime("%Y-%m-%d %H:%M:%S %z"),
          'excerpt' => excerpt.to_s
        }
        data['published'] = false if status != STATUS_PUBLISHED

        yaml_front_matter = data.delete_if { |k,v| v.nil? || v == '' }.to_yaml

        File.open("_posts/#{name}", "w") do |f|
          f.puts yaml_front_matter
          f.puts "---"
          f.puts content
        end
      end
    end

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
