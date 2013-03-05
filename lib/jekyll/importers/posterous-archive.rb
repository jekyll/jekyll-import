require 'rubygems'
require 'jekyll'
require 'fileutils'
require 'find'
require 'nokogiri'
require 'pathname'

#
# Convert posts contained within an unzipped posterous archive into jekyll
# _posts/ files.
#
# Steps:
#    1. Download your posterous blog before April 30th 2013.
#    2. Unzip your posterous archive to e.g. '/home/blah/post-space/'.
#    3. Change directory to your jekyll blog directory (or to an empty directory).
#    4. Run posterous-archive.rb:
#
#        ruby -r './lib/jekyll/importers/posterous-archive.rb' -e 'Jekyll::Posterous.process("/home/blah/post-space")'
#
#    5. The importer will create a '_posts' directory, containing a markdown
#       file for each post, and an 'img' directory, containing any images from
#       each post.
#

module Jekyll
  module Posterous

    def self.loadpost(postfile)

      post = Hash.new

      File.open(postfile, "r") do |f|

        page = Nokogiri::HTML(f)

        post["title"]  = page.css("div.post_header h3").text
        post["date"]   = page.css("div.post_info span.post_time").text
        post["body"]   = page.css("div.post_body").text
        post["images"] = page.css("div.post_body img").map{|i| Pathname.new(i["src"]).basename}
      end

      post
    end

    def self.process(archivedir)
      FileUtils.mkdir_p "_posts"

      # all html files in the 'archive/posts' directory 
      # are considered to be blog posts
      posts = []
      Find.find('%s/posts' % [archivedir]) do |file|
        if file =~ /^.*\.html$/
          posts << self.loadpost(file)
        end
      end

      posts.each do |post|

        title   = post["title"]
        slug    = title.gsub(/[^[:alnum:]]+/, '-').downcase
        date    = Date.parse(post["date"])
        content = post["body"]
        name    = "%02d-%02d-%02d-%s" % [date.year, date.month, date.day, slug]

        if post["images"].any?

          imgdir = "imgs/%s" % name
          FileUtils.mkdir_p imgdir

          img_urls = Array.new 
          post["images"].each do |img|

            imgsrc = "%s/image/%04d/%02d/%s" % [archivedir, date.year, date.month, img]

            FileUtils.copy(imgsrc, imgdir)
            img_urls.push('<li><img src="/%s/%s"></li>' % [imgdir, img])
          end

          content = content + "<ol>" + img_urls.join("\n") + "</ol>\n"
        end

        # Get the relevant fields as a hash, delete empty fields and convert
        # to YAML for the header
        data = {
          'layout' => 'post',
          'title' => title.to_s
        }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

        # Write out the data and content to file
        File.open("_posts/#{name}.html", "w") do |f|
          f.puts data
          f.puts "---"
          f.puts content
        end
      end
    end
  end
end
