# frozen_string_literal: true

module JekyllImport
  module Importers
    class Posterous < Importer
      def self.specify_options(c)
        c.option "email",     "--email EMAIL", "Posterous email address"
        c.option "password",  "--password PW", "Posterous password"
        c.option "api_token", "--token TOKEN", "Posterous API Token"
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          rubygems
          jekyll
          fileutils
          uri
          json
          net/http
        ))
      end

      def self.fetch(uri_str, limit = 10)
        # You should choose better exception.
        raise ArgumentError, "Stuck in a redirect loop. Please double check your email and password" if limit.zero?

        response = nil
        Net::HTTP.start("posterous.com") do |http|
          req = Net::HTTP::Get.new(uri_str)
          req.basic_auth @email, @pass
          response = http.request(req)
        end

        case response
        when Net::HTTPSuccess     then response
        when Net::HTTPRedirection then fetch(response["location"], limit - 1)
        else response.error!
        end
      end

      def self.fetch_images(directory, imgs)
        def self.fetch_one(url, limit = 10)
          raise ArgumentError, "HTTP redirect too deep" if limit.zero?

          response = Net::HTTP.get_response(URI.parse(url))
          case response
          when Net::HTTPSuccess     then response.body
          when Net::HTTPRedirection then fetch_one(response["location"], limit - 1)
          else
            response.error!
          end
        end

        FileUtils.mkdir_p directory
        urls = []
        imgs.each do |img|
          fullurl = img["full"]["url"]
          uri = URI.parse(fullurl)
          imgname = uri.path.split("/")[-1]
          imgdata = fetch_one(fullurl)
          File.open(directory + "/" + imgname, "wb") do |file|
            file.write imgdata
          end
          urls.push(directory + "/" + imgname)
        end

        urls
      end

      def self.process(options)
        email     = options.fetch("email")
        pass      = options.fetch("password")
        api_token = options.fetch("api_token")

        @email = email
        @pass = pass
        @api_token = api_token
        defaults = { :include_imgs => false, :blog => "primary", :base_path => "/" }
        opts = defaults.merge(opts)
        FileUtils.mkdir_p "_posts"

        posts = JSON.parse(fetch("/api/v2/users/me/sites/#{opts[:blog]}/posts?api_token=#{@api_token}").body)
        page = 1

        while posts.any?
          posts.each do |post|
            title = post["title"]
            slug = title.gsub(%r![^[:alnum:]]+!, "-").downcase
            date = Date.parse(post["display_date"])
            content = post["body_html"]
            published = !post["is_private"]
            basename = format("%02d-%02d-%02d-%s", date.year, date.month, date.day, slug)
            name = basename + ".html"

            # Images:
            if opts[:include_imgs]
              post_imgs = post["media"]["images"]
              if post_imgs.any?
                img_dir = format("imgs/%s", basename)
                img_urls = fetch_images(img_dir, post_imgs)

                img_urls.map! do |url|
                  '<li><img src="' + opts[:base_path] + url + '"></li>'
                end
                imgcontent = "<ol>\n" + img_urls.join("\n") + "</ol>\n"

                # filter out "posterous-content", replacing with imgs:
                content = content.sub(%r!\<p\>\[\[posterous-content:[^\]]+\]\]\<\/p\>!, imgcontent)
              end
            end

            # Get the relevant fields as a hash, delete empty fields and convert
            # to YAML for the header
            data = {
              "layout"    => "post",
              "title"     => title.to_s,
              "published" => published,
            }.delete_if { |_k, v| v.nil? || v == "" }.to_yaml

            # Write out the data and content to file
            File.open("_posts/#{name}", "w") do |f|
              f.puts data
              f.puts "---"
              f.puts content
            end
          end

          page += 1
          posts = JSON.parse(fetch("/api/v2/users/me/sites/#{opts[:blog]}/posts?api_token=#{@api_token}&page=#{page}").body)
        end
      end
    end
  end
end
