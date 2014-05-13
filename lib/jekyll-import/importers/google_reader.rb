module JekyllImport
  module Importers
    class GoogleReader < Importer
      def self.validate(options)
        if options['source'].nil?
          abort "Missing mandatory option --source."
        end
      end

      def self.specify_options(c)
        c.option 'source', '--source', 'Source XML file of Google Reader export'
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          rss
          fileutils
          safe_yaml
          open-uri
          rexml/document
          date
        ])
      end

      # Process the import.
      #
      # source - a URL or a local file String.
      #
      # Returns nothing.
      def self.process(options)
        source = options.fetch('source')

        open(source) do |content|
          feed = RSS::Parser.parse(content)

          raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless feed

          feed.items.each do |item|
            title = item.title.content.to_s
            formatted_date = Date.parse(item.published.to_s)
            post_name = title.split(%r{ |!|/|:|&|-|$|,}).map do |i|
              i.downcase if i != ''
            end.compact.join('-')
            name = "#{formatted_date}-#{post_name}"

            header = {
              'layout' => 'post',
              'title' => title
            }

            FileUtils.mkdir_p("_posts")

            File.open("_posts/#{name}.html", "w") do |f|
              f.puts header.to_yaml
              f.puts "---\n\n"
              f.puts item.content.content.to_s
            end
          end
        end
      end
    end
  end
end
