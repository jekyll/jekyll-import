# frozen_string_literal: true

# Tested with dotClear 2.1.5
module JekyllImport
  module Importers
    class Dotclear < Importer
      def self.specify_options(c)
        c.option "datafile", "--datafile PATH", "dotClear export file"
        c.option "mediafolder", "--mediafolder PATH", "dotClear media export folder (media.zip inflated)"
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          rubygems
          fileutils
          safe_yaml
          date
          active_support
          active_support/core_ext/string/inflections
          csv
          pp
        ))
      end

      def self.validate(opts)
        abort "Specify a data file !" if opts["datafile"].nil? || opts["datafile"].empty?
        abort "Specify a media folder !" if opts["mediafolder"].nil? || opts["mediafolder"].empty?
      end

      def self.extract_headers_section(str)
        str[1..-2].split(" ")[1].split(",")
      end

      def self.extract_data_section(str)
        str.gsub(%r!^"!, "").gsub(%r!"$!, "").split('","')
      end

      def self.process(opts)
        options = {
          :datafile    => opts.fetch("datafile", ""),
          :mediafolder => opts.fetch("mediafolder", ""),
        }

        FileUtils.mkdir_p("_posts")
        FileUtils.mkdir_p("_drafts")

        type_data = ""
        headers = {}
        posts_and_drafts = {}
        keywords = {}

        File.readlines(options[:datafile]).each do |lineraw|
          line = lineraw.strip.gsub(%r!\n$!, "")

          next if line.empty?

          if line.start_with?("[") # post | media \ meta | comment...
            type_data = line.split(" ").first[1..-1]
            headers[type_data] = extract_headers_section(line)
            next
          end

          elts = extract_data_section(line)

          if type_data == "post"
            draft = (elts[headers[type_data].index("post_status")] != "1")

            date_str = elts[headers[type_data].index("post_creadt")]
            date_blank = (date_str.nil? || date_str.empty?)
            date_str_formatted = date_blank ? Date.today : Date.parse(date_str).strftime("%Y-%m-%d")
            title_param = elts[headers[type_data].index("post_title")].to_s.parameterize

            content = elts[headers[type_data].index("post_content_xhtml")].to_s
            content = content.gsub('\"', '"').gsub('\n', "\n").gsub("/public/", "/assets/images/")

            filepath = File.join(Dir.pwd, (draft ? "_drafts" : "_posts"), "#{date_str_formatted}-#{title_param}.html")

            entire_content_file = <<~POST_FILE
              ---
              layout: post
              title: "#{elts[headers[type_data].index("post_title")]}"
              date: #{elts[headers[type_data].index("post_creadt")]} +0100
              tags: ABC
              ---

              #{content}
            POST_FILE

            posts_and_drafts[elts[headers[type_data].index("post_id")]] = { :path => filepath, :content => entire_content_file }
          elsif type_data == "media"
            elts[headers[type_data].index("media_title")]
            mediafilepath = elts[headers[type_data].index("media_file")]

            src_path = File.join(options[:mediafolder], mediafilepath)
            dst_path = File.join(Dir.pwd, "assets", "images", mediafilepath.to_s)

            FileUtils.mkdir_p(File.dirname(dst_path))
            FileUtils.cp(src_path, dst_path)
          elsif type_data == "meta"
            keywords[elts[headers[type_data].index("post_id")]] ||= []
            keywords[elts[headers[type_data].index("post_id")]] << elts[headers[type_data].index("meta_id")]
          elsif type_data == "link"

          elsif type_data == "setting"

          elsif type_data == "comment"

          end
        end

        # POST-process : Change media path in posts and drafts
        posts_and_drafts.each do |post_id, hsh|
          keywords_str = keywords[post_id].to_a.join(", ")
          content_file = hsh[:content]
          content_file = content_file.gsub("tags: ABC", "tags: [#{keywords_str}]")

          File.open(hsh[:path], "wb") do |f|
            f.write(content_file)
          end
        end
      end
    end
  end
end
