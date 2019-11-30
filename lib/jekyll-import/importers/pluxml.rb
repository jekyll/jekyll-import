# Inspired by https://github.com/jekyll/jekyll-import/blob/v0.14.0/lib/jekyll-import/importers/rss.rb
# Adapted for PluXML sources

module JekyllImport
  module Importers
    class Pluxml < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          nokogiri
          fileutils
          safe_yaml
        ))
      end

      def self.specify_options(c)
        c.option "source", "--source NAME", "The XML file to import"
        c.option "layout", "--layout NAME", "The layout to apply"
      end

      def self.validate(options)
        if options["source"].nil?
          abort "Missing mandatory option --source."
        end
        if options["layout"].nil?
          options["layout"] = "post"
        end
      end

      def self.process(options)
        source = options.fetch("source")
        layout = options.fetch("layout")

        FileUtils.mkdir_p("_posts")
        FileUtils.mkdir_p("_drafts")

        Dir.glob("*.xml", base: source).each do |df|
          df = File.join(source, df)
          filename = File.basename(df, ".*")
          directory = if filename.split('.')[1].split(',')[0] == 'draft'
                        '_drafts'
                      else
                        '_posts'
                      end
          a_filename = filename.split('.')
          post_name = a_filename.pop
          file_date = a_filename.pop
          post_date = file_date[0..3]+'-'+file_date[4..5]+'-'+file_date[6..7]

          xml = File.open(df) { |f| Nokogiri::XML(f) }

          raise "There doesn't appear to be any XML items at the source (#{df}) provided." unless xml

          doc = xml.xpath('document')
          name = "#{post_date}-#{post_name}"

          header = {
            "layout" => layout,
            "title"  => doc.xpath('title').text,
            "tags"   => doc.xpath('tags').text,
          }

          path = File.join(directory, "#{name}.html")

          File.open(path, "w") do |f|
            f.puts header.to_yaml
            f.puts "---\n\n"
            f.puts doc.xpath('chapo').text
            f.puts doc.xpath('content').text
          end

          puts "Writed file #{path} successfully!"
        end
        nil
      end
    end
  end
end
