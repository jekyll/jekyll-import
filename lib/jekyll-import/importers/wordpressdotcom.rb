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
          open_uri_redirections
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

          i["src"] = "{{ site.baseurl }}/%s/%s" % [assets_folder, File.basename(uri)]
          dst = File.join(assets_folder, File.basename(uri))
          puts "  " + uri
          if File.exist?(dst)
            puts "    Already in cache. Clean assets folder if you want a redownload."
            next
          end
          begin
            open(uri, allow_redirections: :safe) {|f|
              File.open(dst, "wb") do |out|
                out.puts f.read
              end
            }
            puts "    OK!"
          rescue => e
            puts "    Error: #{e.message}"
            puts e.backtrace.join("\n")
          end
        end
      end

      class Item
        def initialize(node)
          @node = node
        end

        def text_for(path)
          @node.at(path).inner_text
        end

        def title
          @title ||= text_for(:title).strip
        end

        def permalink_title
          post_name = text_for('wp:post_name')
          # Fallback to "prettified" title if post_name is empty (can happen)
          @permalink_title ||= if post_name.empty?
            WordpressDotCom.sluggify(title)
          else
            post_name
          end
        end

        def published_at
          if published?
            @published_at ||= Time.parse(text_for('wp:post_date'))
          end
        end

        def status
          @status ||= text_for('wp:status')
        end

        def post_type
          @post_type ||= text_for('wp:post_type')
        end

        def file_name
          @file_name ||= if published?
            "#{published_at.strftime('%Y-%m-%d')}-#{permalink_title}.html"
          else
            "#{permalink_title}.html"
          end
        end

        def directory_name
          @directory_name ||= if !published? && post_type == 'post'
            '_drafts'
          else
            "_#{post_type}s"
          end
        end

        def published?
          @published ||= (status == 'publish')
        end

        def excerpt
          @excerpt ||= begin
            text = Hpricot(text_for('excerpt:encoded')).inner_text
            if text.empty?
              nil
            else
              text
            end
          end
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
          categories = node.search('category[@domain="category"]').map(&:inner_text).reject{|c| c == 'Uncategorized'}.uniq
          tags = node.search('category[@domain="post_tag"]').map(&:inner_text).uniq

          metas = Hash.new
          node.search("wp:postmeta").each do |meta|
            key = meta.at('wp:meta_key').inner_text
            value = meta.at('wp:meta_value').inner_text
            metas[key] = value
          end

          author_login = item.text_for('dc:creator').strip

          header = {
            'layout'     => item.post_type,
            'title'      => item.title,
            'date'       => item.published_at,
            'type'       => item.post_type,
            'published'  => item.published?,
            'status'     => item.status,
            'categories' => categories,
            'tags'       => tags,
            'meta'       => metas,
            'author'     => authors[author_login]
          }

          begin
            content = Hpricot(item.text_for('content:encoded'))
            header['excerpt'] = item.excerpt if item.excerpt

            if fetch
              download_images(item.title, content, assets_folder)
            end

            FileUtils.mkdir_p item.directory_name
            File.open(File.join(item.directory_name, item.file_name), "w") do |f|
              f.puts header.to_yaml
              f.puts '---'
              f.puts Util.wpautop(content.to_html)
            end
          rescue => e
            puts "Couldn't import post!"
            puts "Title: #{item.title}"
            puts "Name/Slug: #{item.file_name}\n"
            puts "Error: #{e.message}"
            next
          end

          import_count[item.post_type] += 1
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
