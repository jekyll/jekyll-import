module JekyllImport
  module Importers
    class Ghost < Importer
      def self.specify_options(c)
        c.option "dbfile", "--dbfile", "Database file (default: ghost.db)"
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          rubygems
          sequel
          sqlite3
          fileutils
          safe_yaml
        ))
      end

      def self.process(options)
        posts = fetch_posts(options.fetch("dbfile", "ghost.db"))
        unless posts.empty?
          FileUtils.mkdir_p("_posts")
          FileUtils.mkdir_p("_drafts")
          posts.each do |post|
            write_post_to_file(post)
          end
        end
      end

      private
      class << self
        def fetch_posts(dbfile)
          db = Sequel.sqlite(dbfile)
          query = "SELECT `title`, `slug`, `markdown`, `created_at`, `published_at`, `status`, `page` FROM posts"
          db[query]
        end

        def write_post_to_file(post)
          # detect if the post is a draft
          draft = post[:status].eql?("draft")

          # detect if the post is considered a static page
          page = post[:page]

          # the publish date if the post has been published, creation date otherwise
          date = Time.at(post[draft ? :created_at : :published_at].to_i)

          if page
            # the filename under which the page is stored
            filename = "#{post[:slug]}.markdown"
          else
            # the directory where the file will be saved to. either _drafts or _posts
            directory = draft ? "_drafts" : "_posts"

            # the filename under which the post is stored
            filename = File.join(directory, "#{date.strftime("%Y-%m-%d")}-#{post[:slug]}.markdown")
          end

          # the YAML FrontMatter
          frontmatter = {
            "layout" => page ? "page" : "post",
            "title"  => post[:title],
          }
          frontmatter["date"] = date if !page && !draft # only add the date to the frontmatter when the post is published
          frontmatter["published"] = false if page && draft # set published to false for draft pages
          frontmatter.delete_if { |_k, v| v.nil? || v == "" } # removes empty fields

          # write the posts to disk
          write_file(filename, frontmatter.to_yaml, post[:markdown])
        end

        def write_file(filename, frontmatter, content)
          File.open(filename, "w") do |f|
            f.puts frontmatter
            f.puts "---"
            f.puts content
          end
        end
      end
    end
  end
end
