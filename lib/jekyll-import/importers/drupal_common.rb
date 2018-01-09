require "date"

module JekyllImport
  module Importers
    module DrupalCommon
      # This module provides a base for the Drupal importers (at least for 6
      # and 7; since 8 will be a different beast). Version-specific importers
      # will need to implement the missing methods from the Importer class.
      #
      # The general idea is that this importer reads a MySQL database via Sequel
      # and creates a post file for each node it finds in the Drupal database.

      module ClassMethods
        DEFAULTS = {
          "engine"   => "mysql",
          "password" => "",
          "host"     => "localhost",
          "prefix"   => "",
          "types"    => %w(blog story article),
        }.freeze

        def specify_options(c)
          c.option "engine", "--engine [mysql|postgresql]", "Database engine (default: #{DEFAULTS["engine"].inspect})"
          c.option "dbname", "--dbname DB", "Database name"
          c.option "user", "--user USER", "Database user name"
          c.option "password", "--password PW", "Database user's password (default: #{DEFAULTS["password"].inspect})"
          c.option "host", "--host HOST", "Database host name (default: #{DEFAULTS["host"].inspect})"
          c.option "prefix", "--prefix PREFIX", "Table prefix name (default: #{DEFAULTS["prefix"].inspect})"
          c.option "types", "--types TYPE1[,TYPE2[,TYPE3...]]", Array,
            "The Drupal content types to be imported  (default: #{DEFAULTS["types"].join(",")})"
        end

        def require_deps
          JekyllImport.require_with_fallback(%w(
            rubygems
            sequel
            mysql2
            pg
            fileutils
            safe_yaml
          ))
        end

        def process(options)
          engine = options.fetch("engine")
          dbname = options.fetch("dbname")
          user   = options.fetch("user")
          pass   = options.fetch("password", DEFAULTS["password"])
          host   = options.fetch("host",     DEFAULTS["host"])
          prefix = options.fetch("prefix",   DEFAULTS["prefix"])
          types  = options.fetch("types",    DEFAULTS["types"])

          if engine == "postgresql"
            db = Sequel.postgres(dbname, :user => user, :password => pass, :host => host, :encoding => "utf8")
          else
            db = Sequel.mysql2(dbname, :user => user, :password => pass, :host => host, :encoding => "utf8")
          end

          query = self.build_query(prefix, types, engine)

          conf = Jekyll.configuration({})
          src_dir = conf["source"]

          dirs = {
            :_posts   => File.join(src_dir, "_posts").to_s,
            :_drafts  => File.join(src_dir, "_drafts").to_s,
            :_layouts => Jekyll.sanitized_path(src_dir, conf["layouts_dir"].to_s),
          }

          dirs.each do |_key, dir|
            FileUtils.mkdir_p dir
          end

          # Create the refresh layout
          # Change the refresh url if you customized your permalink config
          File.open(File.join(dirs[:_layouts], "refresh.html"), "w") do |f|
            f.puts <<-HTML
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta http-equiv="refresh" content="0;url={{ page.refresh_to_post_id }}.html" />
</head>
</html>
HTML
          end

          db[query].each do |post|
            # Get required fields
            data, content = self.post_data(post)

            data["layout"] = post[:type]
            title = data["title"] = post[:title].strip.force_encoding("UTF-8")
            time = data["created"] = post[:created]

            # Get the relevant fields as a hash and delete empty fields
            data = data.delete_if { |_k, v| v.nil? || v == "" }.each_pair do |_k, v|
              ((v.is_a? String) ? v.force_encoding("UTF-8") : v)
            end

            # Construct a Jekyll compatible file name
            is_published = post[:status] == 1
            node_id = post[:nid]
            dir = is_published ? dirs[:_posts] : dirs[:_drafts]
            slug = title.strip.downcase.gsub(%r!(&|&amp;)!, " and ").gsub(%r![\s\.\/\\]!, "-").gsub(%r![^\w-]!, "").gsub(%r![-_]{2,}!, "-").gsub(%r!^[-_]!, "").gsub(%r![-_]$!, "")
            filename = Time.at(time).to_datetime.strftime("%Y-%m-%d-") + slug + ".md"

            # Write out the data and content to file
            File.open("#{dir}/#{filename}", "w") do |f|
              f.puts data.to_yaml
              f.puts "---"
              f.puts content
            end

            # Make a file to redirect from the old Drupal URL
            next unless is_published
            alias_query = self.aliases_query(prefix)
            type = post[:type]

            aliases = db[alias_query, "#{type}/#{node_id}"].all

            aliases.push(:alias => "#{type}/#{node_id}")

            aliases.each do |url_alias|
              FileUtils.mkdir_p url_alias[:alias]
              File.open("#{url_alias[:alias]}/index.md", "w") do |f|
                f.puts "---"
                f.puts "layout: refresh"
                f.puts "refresh_to_post_id: /#{Time.at(time).to_datetime.strftime("%Y/%m/%d/") + slug}"
                f.puts "---"
              end
            end
          end
        end
      end

      def build_query(_prefix, _types, _engine)
        raise "The importer you are trying to use does not implement the get_query() method."
      end

      def aliases_query(_prefix)
        # Make sure you implement the query returning "alias" as the column name
        # for the URL aliases. See the Drupal 6 importer for an example. The
        # alias field is called 'dst' but we alias it to 'alias', to follow
        # Drupal 7's column names.
        raise "The importer you are trying to use does not implement the get_aliases_query() method."
      end

      def post_data(_sql_post_data)
        raise "The importer you are trying to use does not implement the get_query() method."
      end

      def validate(options)
        %w(dbname user).each do |option|
          if options[option].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

    end
  end
end
