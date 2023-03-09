# frozen_string_literal: true

module JekyllImport
  module Importers
    class Dotclear < Importer
      class << self
        def specify_options(c)
          c.option "datafile",    "--datafile PATH",   "Dotclear export file."
          c.option "mediafolder", "--mediafolder DIR", "Dotclear media export folder (unpacked media.zip)."
        end

        def require_deps
          JekyllImport.require_with_fallback(%w())
        end

        def validate(opts)
          file_path = opts["datafile"]
          log_undefined_flag_error("datafile") if file_path.nil? || file_path.empty?

          file_path = File.expand_path(file_path)
          if File.open(file_path, "rb", &:readline).start_with?("///DOTCLEAR|")
            @data = read_export(file_path)
            Jekyll.logger.info "Export File:", file_path
          else
            Jekyll.logger.abort_with "Import Error:", "#{file_path.inspect} is not a valid Dotclear export file!"
          end

          assets = @data["media"]
          return if !assets || assets.empty?

          Jekyll.logger.info "", "Media files detected in export data."

          media_dir = opts["mediafolder"]
          log_undefined_flag_error("mediafolder") if media_dir.nil? || media_dir.empty?

          media_dir = File.expand_path(media_dir)
          log_invalid_media_dir_error(media_dir) if !File.directory?(media_dir) || Dir.empty?(media_dir)
        end

        def process(opts)
          import_posts
          import_assets(opts["mediafolder"])
          Jekyll.logger.info "", "and, done!"
        end

        private

        # Parse backup sections into a Hash of arrays.
        #
        # Each section is of following shape:
        #
        #   [key alpha,beta,gamma,...]
        #   lorem,ipsum,dolor,...
        #   red,blue,green,...
        #
        # Returns Hash of shape:
        #
        #   {key => [{alpha => lorem,...}, {alpha => red,...}]}
        #
        def read_export(file)
          ignored_sections = %w(category comment link setting)

          File.read(file, :encoding => "utf-8").split("\n\n").each_with_object({}) do |section, data|
            next unless %r!^\[(?<key>.*?) (?<header>.*)\]\n(?<rows>.*)!m =~ section
            next if ignored_sections.include?(key)

            headers = header.split(",")

            data[key] = rows.each_line.with_object([]) do |line, bucket|
              bucket << headers.zip(sanitize_line!(line)).to_h
            end

            data
          end
        end

        def register_post_tags
          @data["meta"].each_with_object({}) do |entry, tags|
            next unless entry["meta_type"] == "tag"

            post_id = entry["post_id"]
            tags[post_id] ||= []
            tags[post_id] << entry["meta_id"]
          end
        end

        def log_undefined_flag_error(label)
          Jekyll.logger.abort_with "Import Error:", "--#{label} flag cannot be undefined, null or empty!"
        end

        def log_invalid_media_dir_error(media_dir)
          Jekyll.logger.error "Import Error:", "--mediafolder should be a non-empty directory."
          Jekyll.logger.abort_with "", "Please check #{media_dir.inspect}."
        end

        def sanitize_line!(line)
          line.strip!
          line.split('","').tap do |items|
            items[0].delete_prefix!('"')
            items[-1].delete_suffix!('"')
          end
        end

        # -

        REPLACE_MAP = {
          '\"'                => '"',
          '\r\n'              => "\n",
          '\n'                => "\n",
          "/dotclear/public/" => "/assets/dotclear/",
          "/public/"          => "/assets/dotclear/",
        }.freeze

        REPLACE_RE = Regexp.union(REPLACE_MAP.keys)

        private_constant :REPLACE_MAP, :REPLACE_RE

        # -

        def adjust_post_contents!(content)
          content.strip!
          content.gsub!(REPLACE_RE, REPLACE_MAP)
          content
        end

        def import_posts
          tags = register_post_tags
          posts = @data["post"]

          FileUtils.mkdir_p("_drafts") unless posts.empty?
          Jekyll.logger.info "Importing posts.."

          posts.each do |post|
            date, title = post.values_at("post_creadt", "post_title")
            path = File.join("_drafts", Date.parse(date).strftime("%Y-%m-%d-") + Jekyll::Utils.slugify(title) + ".html")

            excerpt = adjust_post_contents!(post["post_excerpt_xhtml"].to_s)
            excerpt = nil if excerpt.empty?

            # Unlike the paradigm in Jekyll-generated HTML, `post_content_xhtml` in the export data
            # doesn't begin with `post_excerpt_xhtml`.
            # Instead of checking whether the excerpt content exists elsewhere in the exported content
            # string, always prepend excerpt onto content with an empty line in between.
            content = [excerpt, post["post_content_xhtml"]].tap(&:compact!).join("\n\n")

            front_matter_data = {
              "layout"       => "post",
              "title"        => title,
              "date"         => date,
              "lang"         => post["post_lang"],
              "tags"         => tags[post["post_id"]],
              "original_url" => post["post_url"], # URL as included in the export-file.
              "excerpt"      => excerpt,
            }.tap(&:compact!)

            Jekyll.logger.info "Creating:", path
            File.write(path, "#{YAML.dump(front_matter_data)}---\n\n#{adjust_post_contents!(content)}\n")
          end
        end

        def import_assets(src_dir)
          assets = @data["media"]
          FileUtils.mkdir_p("assets/dotclear") if assets && !assets.empty?
          Jekyll.logger.info "Importing assets.."

          assets.each do |asset|
            file_path = File.join(src_dir, asset["media_file"])
            if File.exist?(file_path)
              dest_path = File.join("assets/dotclear", asset["media_file"])
              FileUtils.mkdir_p(File.dirname(dest_path))

              Jekyll.logger.info "Copying:", file_path
              Jekyll.logger.info "To:", dest_path
              FileUtils.cp_r file_path, dest_path
            else
              Jekyll.logger.info "Not found:", file_path
            end
          end
        end
      end
    end
  end
end
