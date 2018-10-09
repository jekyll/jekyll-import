# frozen_string_literal: true

module JekyllImport
  module Importers
    class RSS < Importer
      def self.specify_options(c)
        c.option "source", "--source NAME", "The RSS file or URL to import"
        c.option "tag", "--tag NAME", "Add a tag to posts"
      end

      def self.validate(options)
        abort "Missing mandatory option --source." if options["source"].nil?
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          rss
          rss/1.0
          rss/2.0
          open-uri
          fileutils
          safe_yaml
        ))
      end

      # Process the import.
      #
      # source - a URL or a local file String.
      #
      # Returns nothing.
      def self.process(options)
        source = options.fetch("source")
        frontmatter = options.fetch("frontmatter", [])
        body = options.fetch("body", ["description"])

        content = ""
        URI.parse(source).open { |s| content = s.read }
        rss = ::RSS::Parser.parse(content, false)

        raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless rss

        rss.items.each do |item|
          formatted_date = item.date.strftime("%Y-%m-%d")
          post_name = item.title.split(%r{ |!|/|:|&|-|$|,}).map do |i|
            i.downcase if i != ""
          end.compact.join("-")
          name = "#{formatted_date}-#{post_name}"

          header = {
            "layout" => "post",
            "title"  => item.title,
          }

          header["tag"] = options["tag"] unless options.to_s.empty?

          frontmatter.each do |value|
            header[value] = item.send(value)
          end

          output = ""

          body.each do |row|
            output += item.send(row)
          end

          FileUtils.mkdir_p("_posts")

          File.open("_posts/#{name}.html", "w") do |f|
            f.puts header.to_yaml
            f.puts "---\n\n"
            f.puts output
          end
        end
      end
    end
  end
end
