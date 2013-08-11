# coding: utf-8

require 'rubygems'
require 'hpricot'
require 'fileutils'
require 'safe_yaml'
require 'time'

module JekyllImport
  # This importer takes a wordpress.xml file, which can be exported from your
  # wordpress.com blog (/wp-admin/export.php).
  module WordpressDotCom
    def self.process(filename = {:source => "wordpress.xml"})
      import_count = Hash.new(0)
      doc = Hpricot::XML(File.read(filename[:source]))

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

        author_login = item.at('dc:creator').inner_text.strip

        name = "#{date.strftime('%Y-%m-%d')}-#{permalink_title}.html"
        header = {
          'layout' => type,
          'title'  => title,
          'categories' => categories,
          'tags'   => tags,
          'status'   => status,
          'type'   => type,
          'published' => published,
          'meta'   => metas,
          'author' => authors[author_login]
        }

        begin
          FileUtils.mkdir_p "_#{type}s"
          File.open("_#{type}s/#{name}", "w") do |f|
            f.puts header.to_yaml
            f.puts '---'
            f.puts item.at('content:encoded').inner_text
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
