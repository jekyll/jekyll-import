# encoding: UTF-8

module JekyllImport
  module Importers
    class WordpressDotCom < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          fileutils
          safe_yaml
          hpricot
          time
          open-uri
        ])
      end

      def self.specify_options(c)
        c.option 'source', '--source FILE', 'WordPress export XML file (default: "wordpress.xml")'
        c.option 'no_fetch_images', '--no-fetch-images', 'Do not fetch the images referenced in the posts'
        c.option 'assets_folder', '--assets_folder FOLDER', 'Folder where assets such as images will be downloaded to (default: assets)'
      end

      # Will modify post DOM tree
      def self.download_images(title, post_hpricot, assets_folder)
        images = (post_hpricot/"img")
        if images.length == 0
          return
        end
        puts "Downloading images for " + title
        images.each do |i|
          uri = i["src"]

          i["src"] = assets_folder + "/" + File.basename(uri)
          dst = File.join(assets_folder, File.basename(uri))
          puts "  " + uri
          if File.exist?(dst)
            puts "    Already in cache. Clean assets folder if you want a redownload."
            next
          end
          begin
            open(uri) {|f|
              File.open(dst, "wb") do |out|
                out.puts f.read
              end
            }
            puts "    OK!"
          rescue => e
            puts "    Errorr: #{e.message}"
          end
        end
      end

      class Item
        def initialize(node)
          @node = node
        end

        def title
          @node.at(:title).inner_text.strip
        end

        def permalink_title
          p_title = @node.at('wp:post_name').inner_text
          # Fallback to "prettified" title if post_name is empty (can happen)
          if p_title == ""
            p_title = WordpressDotCom.sluggify(title)
          end

          return p_title
        end

        def published_at
          Time.parse(@node.at('wp:post_date').inner_text)
        end

        def status
          @node.at('wp:status').inner_text
        end

        def post_type
          @node.at('wp:post_type').inner_text
        end

        def file_name
          "#{published_at.strftime('%Y-%m-%d')}-#{permalink_title}.html"
        end

        def directory_name
          "_#{post_type}s"
        end

        def published?
          status == 'publish'
        end
      end

      def self.process(options)
        source        = options.fetch('source', "wordpress.xml")
        fetch         = !options.fetch('no_fetch_images', false)
        assets_folder = options.fetch('assets_folder', 'assets')
        FileUtils.mkdir_p(assets_folder)

        import_count = Hash.new(0)
        doc = Hpricot::XML(File.read(source))
        # Fetch authors data from header
        authors = Hash[
          (doc/:channel/'wp:author').map do |author|
          [author.at("wp:author_login").inner_text.strip, {
            "login" => author.at("wp:author_login").inner_text.strip,
            "email" => author.at("wp:author_email").inner_text,
            "display_name" => author.at("wp:author_display_name").inner_text,
            "first_name" => author.at("wp:author_first_name").inner_text,
            "last_name" => author.at("wp:author_last_name").inner_text
          }]
          end
        ] rescue {}

        (doc/:channel/:item).each do |node|
          item = Item.new(node)
          title = item.title
          permalink_title = item.permalink_title
          date = item.published_at
          status = item.status
          published = item.published?

          type = item.post_type
          categories = node.search('category[@domain="category"]').map{|c| c.inner_text}.reject{|c| c == 'Uncategorized'}.uniq
          tags = node.search('category[@domain="post_tag"]').map{|t| t.inner_text}.uniq

          metas = Hash.new
          node.search("wp:postmeta").each do |meta|
            key = meta.at('wp:meta_key').inner_text
            value = meta.at('wp:meta_value').inner_text
            metas[key] = value
          end

          author_login = node.at('dc:creator').inner_text.strip

          name = item.file_name
          header = {
            'layout' => type,
            'title'  => title,
            'date' => date,
            'categories' => categories,
            'tags'   => tags,
            'status'   => status,
            'type'   => type,
            'published' => published,
            'meta'   => metas,
            'author' => authors[author_login]
          }

          begin
            content = Hpricot(node.at('content:encoded').inner_text)
            excerpt = Hpricot(node.at('excerpt:encoded').inner_text)

            if excerpt
              header['excerpt'] = excerpt
            end

            if fetch
              download_images(title, content, assets_folder)
            end

            FileUtils.mkdir_p item.directory_name
            File.open("#{item.directory_name}/#{name}", "w") do |f|
              f.puts header.to_yaml
              f.puts '---'
              f.puts Util.wpautop(content.to_html)
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
