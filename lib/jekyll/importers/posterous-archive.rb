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
#        ruby -r './lib/jekyll/importers/posterous-archive.rb' -e 'Jekyll::PosterousArchive.process("/home/blah/post-space")'
#
#    5. The importer will create a '_posts' directory, containing a markdown
#       file for each post, and an 'img' directory, containing any images from
#       each post.
#

module Jekyll
  module PosterousArchive

    # Load a posterous html post file, return its contents as a Hash.
    def self.loadpost(postfile)

      post = Hash.new

      File.open(postfile, "r") do |f|

        page = Nokogiri::HTML(f)

        post["title"]  = page.css("div.post_header h3").text
        post["date"]   = page.css("div.post_info span.post_time").text
        post["images"] = page.css("div.post_body img").map{|i| Pathname.new(i["src"]).basename}

        # image links are embedded in the post body, so if we want to preserve
        # any HTML formatting in the post, we must remove the image links, otherwise
        # they will be preserved as part of the content.
        content = page.css("div.post_body")
        content.search("div.p_image_embed").each do |n|
          n.remove()
        end

        post["body"] = content.inner_html

      end

      post
    end

    # Convert a posterous post hash to a jekyll post hash.
    def self.convertpost(post)

      jpost = Hash.new

      jpost["title"]   = post["title"]
      jpost["slug"]    = jpost["title"].gsub(/[^[:alnum:]]+/, '-').downcase
      jpost["date"]    = Date.parse(post["date"])
      datestr          = "%02d-%02d-%02d" % [jpost["date"].year, jpost["date"].month, jpost["date"].day]
      jpost["content"] = post["body"]
      jpost["name"]    = '%s-%s' % [datestr, jpost["slug"]]
      jpost["images"]  = post["images"]

      jpost
    end 

    def self.process(archivedir)
      FileUtils.mkdir_p "_posts"

      # all html files in the 'archive/posts' directory 
      # are considered to be blog posts
      posts = []
      Find.find(File.join("%s" % archivedir, "posts")) do |file|
        if file =~ /^.*\.html$/
          posts << self.loadpost(file)
        end
      end

      posts.each do |post|

        jpost = self.convertpost(post)

        if jpost["images"].any?

          imgdir = File.join("imgs", "%s" % jpost["name"])
          FileUtils.mkdir_p imgdir

          img_urls = Array.new 
          jpost["images"].each do |img|

            imgsrc = File.join("%s" % archivedir, "image", "%04d" % jpost["date"].year, "%02d" % jpost["date"].month, img)

            FileUtils.copy(imgsrc, imgdir)
            img_urls.push('<li><img src="/%s/%s"></li>' % [imgdir, img])
          end

          jpost["content"] = jpost["content"] + "<ol>" + img_urls.join("\n") + "</ol>\n"
        end

        # Get the relevant fields as a hash, delete empty fields and convert
        # to YAML for the header
        data = {
          'layout' => 'post',
          'title' => jpost["title"].to_s
        }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

        # Write out the data and content to file
        File.open(File.join("_posts", "#{jpost['name']}.html"), "w") do |f|
          f.puts data
          f.puts "---"
          f.puts jpost["content"]
        end
      end
    end
  end
end
