# frozen_string_literal: true

module JekyllImport
  module Importers
    class RSS < Importer
      def self.specify_options(c)
        c.option "source",         "--source NAME",      "The RSS file or URL to import."
        c.option "tag",            "--tag NAME",         "Add a specific tag to all posts."
        c.option "extract_tags",   "--extract_tags KEY", "Copies tags from the given subfield on the RSS `<item>` to front matter. (default: null)"
        c.option "render_audio",   "--render_audio",     "Render `<audio>` element in posts for the enclosure URLs. (default: false)"
        c.option "canonical_link", "--canonical_link",   "Add original link as `canonical_url` to post front matter. (default: false)"
      end

      def self.validate(options)
        abort "Missing mandatory option --source." if options["source"].nil?
        abort "Provide either --tag or --extract_tags option." if options["extract_tags"] && options["tag"]
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

        content = ""
        URI.open(source) { |s| content = s.read }
        rss = ::RSS::Parser.parse(content, false)

        raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless rss

        rss.items.each do |item|
          write_rss_item(item, options)
        end
      end

      def self.write_rss_item(item, options)
        frontmatter = options.fetch("frontmatter", [])
        body = options.fetch("body", ["description"])
        render_audio = options.fetch("render_audio", false)

        formatted_date = item.date.strftime("%Y-%m-%d")
        post_name = Jekyll::Utils.slugify(item.title, :mode => "latin")
        name = "#{formatted_date}-#{post_name}"
        audio = render_audio && item.enclosure.url
        canonical_link = options.fetch("canonical_link", false)

        header = {
          "layout"        => "post",
          "title"         => item.title,
          "canonical_url" => (canonical_link ? item.link : nil),
          "tag"           => get_tags(item, options),
        }.compact

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

          if audio
            f.puts <<~HTML
              <audio controls="">
                <source src="#{audio}" type="audio/mpeg">
                Your browser does not support the audio element.
              </audio>
            HTML
          end

          f.puts output
        end
      end

      def self.get_tags(item, options)
        explicit_tag = options["tag"]
        return explicit_tag unless explicit_tag.nil? || explicit_tag.empty?

        tags_reference = options["extract_tags"]
        return unless tags_reference

        tags_from_feed = item.instance_variable_get("@#{tags_reference}")
        return unless tags_from_feed.is_a?(Array)

        tags = tags_from_feed.map { |feed_tag| feed_tag.content.downcase }
        tags.empty? ? nil : tags.tap(&:uniq!)
      end
      private_class_method :get_tags
    end
  end
end
