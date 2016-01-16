# encoding: UTF-8

module JekyllImport
  module Importers
    class CSV < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          csv
          fileutils
          yaml
        ])
      end

      def self.specify_options(c)
        c.option 'file', '--file NAME', 'The CSV file to import (default: "posts.csv")'
        c.option 'no-front-matter', '--no-front-matter', 'Do not add the default front matter to the post body'
      end

      # Reads a csv with title, permalink, body, published_at, and filter.
      # It creates a post file for each row in the csv
      def self.process(options)
        file = options.fetch('file', "posts.csv")

        FileUtils.mkdir_p "_posts"
        posts = 0
        abort "Cannot find the file '#{file}'. Aborting." unless File.file?(file)

        ::CSV.foreach(file) do |row|
          next if row[0] == "title" # header
          posts += 1
          write_post(CSVPost.new(row), options)
        end
        Jekyll.logger.info "Created #{posts} posts!"
      end

      class CSVPost
        attr_reader :title, :permalink, :body, :markup

        MissingDataError = Class.new(RuntimeError)

        # Creates a CSVPost
        #
        # row - Array of data, length of 4 or 5 with the columns:
        #
        #   1. title
        #   2. permalink
        #   3. body
        #   4. published_at
        #   5. markup (markdown, textile)
        def initialize(row)
          @title = row[0]        || missing_data("Post title not present in first column.")
          @permalink = row[1]    || missing_data("Post permalink not present in second column.")
          @body = row[2]         || missing_data("Post body not present in third column.")
          @published_at = row[3] || missing_data("Post publish date not present in fourth column.")
          @markup = row[4]       || "markdown"
        end

        def published_at
          if @published_at && !@published_at.is_a?(DateTime)
            @published_at = DateTime.parse(@published_at)
          else
            @published_at
          end
        end

        def filename
          "#{published_at.strftime("%Y-%m-%d")}-#{File.basename(permalink, ".*")}.#{markup}"
        end

        def missing_data(message)
          raise MissingDataError, message
        end
      end

      def self.write_post(post, options = {})
        File.open(File.join("_posts", post.filename), "w") do |f|
          write_frontmatter(f, post, options)
          f.puts post.body
        end
      end

      def self.write_frontmatter(f, post, options)
        no_frontmatter = options.fetch('no-front-matter', false)
        unless no_frontmatter
          f.puts YAML.dump({
            "layout"    => "post",
            "title"     => post.title,
            "date"      => post.published_at.to_s,
            "permalink" => post.permalink
          })
          f.puts "---"
        end
      end
    end
  end
end
