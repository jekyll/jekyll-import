module JekyllImport
  module Importers
    class Ghost < Importer

      def self.specify_options(c)
        c.option 'dbfile', '--dbfile', 'Database file (default: ghost.db)'
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
        posts = fetch_posts(options.fetch('dbfile', 'ghost.db'))
        if !posts.empty?
          FileUtils.mkdir_p("_posts")
          FileUtils.mkdir_p("_drafts")
          posts.each do |post|
            write_post_to_file(post)
          end
        end
      end

      private
      def self.fetch_posts(dbfile)
        db = Sequel.sqlite(dbfile)
        query = "SELECT `title`, `slug`, `markdown`, `created_at`, `status` FROM posts"
        db[query]
      end

      def self.write_post_to_file(post)
        # detect if the post is a draft
        draft = post[:status].eql?('draft')

        # Ghost saves the time in an weird format with 3 more numbers.
        # But the time is correct when we remove the last 3 numbers.
        date = Time.at(post[:created_at].to_i.to_s[0..-4].to_i)

        # the directory where the file will be saved to. either _drafts or _posts
        directory = draft ? "_drafts" : "_posts"

        # the filename under which the post is stored
        filename = File.join(directory, "#{date.strftime('%Y-%m-%d')}-#{post[:slug]}.markdown")

        # the YAML FrontMatter
        frontmatter = { 'layout' => 'post', 'title' => post[:title] }
        frontmatter['date'] =  date if !draft # only add the date to the frontmatter when the post is published
        frontmatter.delete_if { |k,v| v.nil? || v == '' } # removes empty fields

        # write the posts to disk
        write_file(filename, frontmatter.to_yaml, post[:markdown])
      end

      def self.write_file(filename, frontmatter, content)
        File.open(filename, "w") do |f|
          f.puts frontmatter
          f.puts "---"
          f.puts content
        end
      end
    end
  end
end
