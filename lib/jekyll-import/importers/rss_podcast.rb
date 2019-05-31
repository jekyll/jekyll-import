# frozen_string_literal: true

require_relative "rss"

module JekyllImport
  module Importers
    class RSSPodcast < RSS
      # Process the import.
      #
      # source - a URL or a local file String.
      #
      # Returns nothing.
      def self.process(options)
        source = options.fetch("source")
        frontmatter = options.fetch("frontmatter", [])
        body = options.fetch("body", ["description"])
        overwrite = options.fetch("overwrite", true)

        content = ""
        uri = URI.parse(source)
        uri.open { |s| content = s.read }
        rss = ::RSS::Parser.parse(content, false)

        raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless rss

        rss.items.each do |item|
          formatted_date = item.date.strftime("%Y-%m-%d")
          post_name = Jekyll::Utils.slugify(item.title, :mode => "latin")
          name = "#{formatted_date}-#{post_name}"

          # Skip this file if it already exists and overwrite is turned off
          next if !overwrite && File.file?("_posts/#{name}.html")

          audio = item.enclosure.url

          header = {
            "layout" => "post",
            "title"  => item.title,
          }

          header["tag"] = options["tag"] unless options["tag"].nil? || options["tag"].empty?

          frontmatter.each do |value|
            header[value] = item.send(value)
          end

          output = +""

          body.each do |row|
            output << item.send(row).to_s
          end

          output.strip!
          output = item.content_encoded if output.empty?

          FileUtils.mkdir_p("_posts")

          File.open("_posts/#{name}.html", "w") do |f|
            f.puts header.to_yaml
            f.puts "---\n\n"
            f.puts "<audio controls=\"\"><source src=\"#{audio}\" type=\"audio/mpeg\">Your browser does not support the audio element.</audio>"
            f.puts output
          end
        end
      end
    end
  end
end
