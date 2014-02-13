# coding: utf-8
# This importer takes a wordpress.xml file, which can be exported from your
# wordpress.com blog (/wp-admin/export.php).

module JekyllImport
  module Importers
    class WordpressDotCom < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          sequel
          fileutils
          safe_yaml
          hpricot
          time
        ])
      end

      def self.specify_options(c)
        c.option 'source', '--source FILE', 'WordPress export XML file (default: "wordpress.xml")'
      end

      def self.process(options)
        source = options.fetch('source', "wordpress.xml")

        import_count = Hash.new(0)
        doc = Hpricot::XML(File.read(source))

        (doc/:channel/:item).each do |item|
          title = item.at(:title).inner_text.strip
          permalink_title = item.at('wp:post_name').inner_text
          # Fallback to "prettified" title if post_name is empty (can happen)
          if permalink_title == ""
            permalink_title = sluggify(title)
          end

          date = Time.parse(item.at('wp:post_date').inner_text)
          status = item.at('wp:status').inner_text

          if status == "publish"
            published = true
          else
            published = false
          end

          type = item.at('wp:post_type').inner_text
          categories = item.search('category[@domain="category"]').map{|c| c.inner_text}.reject{|c| c == 'Uncategorized'}.uniq
          tags = item.search('category[@domain="post_tag"]').map{|t| t.inner_text}.uniq

          metas = Hash.new
          item.search("wp:postmeta").each do |meta|
            key = meta.at('wp:meta_key').inner_text
            value = meta.at('wp:meta_value').inner_text
            metas[key] = value;
          end

          name = "#{date.strftime('%Y-%m-%d')}-#{permalink_title}.html"
          header = {
            'layout' => type,
            'title'  => title,
            'categories' => categories,
            'tags'   => tags,
            'status'   => status,
            'type'   => type,
            'published' => published,
            'meta'   => metas
          }

          begin
            FileUtils.mkdir_p "_#{type}s"
            File.open("_#{type}s/#{name}", "w") do |f|
              f.puts header.to_yaml
              f.puts '---'
              f.puts Util.wpautop(item.at('content:encoded').inner_text)
            end
          rescue => e
            puts "Couldn't import post!"
            puts "Title: #{title}"
            puts "Name/Slug: #{name}\n"
            puts "Error: #{e.message}"
            next
          end

          import_count[type] += 1
        end

        import_count.each do |key, value|
          puts "Imported #{value} #{key}s"
        end
      end

      def self.sluggify(title)
        title.gsub(/[^[:alnum:]]+/, '-').downcase
      end
    end
  end
end
