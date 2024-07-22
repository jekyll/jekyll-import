# frozen_string_literal: false

module JekyllImport
  module Importers
    class Pebble < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          nokogiri
          safe_yaml
        ))
      end

      def self.specify_options(c)
        c.option "directory", "--directory PATH", "Pebble source directory"
      end

      def self.process(opts)
        options = { :directory => opts.fetch("directory", "") }

        FileUtils.mkdir_p("_posts")
        FileUtils.mkdir_p("_drafts")

        traverse_posts_within(options[:directory]) do |file|
          next if file.end_with?("categories.xml")

          process_file(file)
        end
      end

      def self.traverse_posts_within(directory, &block)
        Dir.each_child(directory) do |fd|
          path = File.join(directory, fd)
          if File.directory?(path)
            traverse_posts_within(path, &block)
          elsif path.end_with?("xml")
            yield(path) if block_given?
          end
        end
      end

      def self.process_file(file)
        xml = File.open(file) { |f| Nokogiri::XML(f) }
        raise "There doesn't appear to be any XML items at the source (#{file}) provided." unless xml

        doc = xml.xpath("blogEntry")

        title = kebabize(doc.xpath("title").text).tr("_", "-")
        date = Date.parse(doc.xpath("date").text)

        directory = "_posts"
        name = "#{date.strftime("%Y-%m-%d")}-#{title}"

        header = {
          "layout"     => "post",
          "title"      => doc.xpath("title").text,
          "tags"       => doc.xpath("tags").text.split(", "),
          "categories" => doc.xpath("category").text.split(", "),
        }
        header["render_with_liquid"] = false

        path = File.join(directory, "#{name}.html")
        File.open(path, "w") do |f|
          f.puts header.to_yaml
          f.puts "---\n\n"
          f.puts doc.xpath("body").text
        end

        Jekyll.logger.info "Wrote file #{path} successfully!"
      end

      def self.kebabize(string)
        kebab = "-".freeze
        string.gsub!(%r![^\w\-_]+!, kebab)

        unless kebab.nil? || kebab.empty?
          if kebab == "-".freeze
            re_duplicate_kebab        = %r!-{2,}!
            re_leading_trailing_kebab = %r!^-|-$!
          else
            re_sep = Regexp.escape(kebab)
            re_duplicate_kebab = %r!#{re_sep}{2,}!
            re_leading_trailing_kebab = %r!^#{re_sep}|#{re_sep}$!
          end
          # No more than one of the kebab in a row.
          string.gsub!(re_duplicate_kebab, kebab)
          # Remove leading/trailing kebab.
          string.gsub!(re_leading_trailing_kebab, "".freeze)
        end

        string.downcase!
        string
      end
    end
  end
end
