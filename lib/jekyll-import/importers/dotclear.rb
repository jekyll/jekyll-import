# frozen_string_literal: true

module JekyllImport
  module Importers
    class Dotclear < Importer
      class << self
        def specify_options(c)
          c.option "datafile", "--datafile PATH", "Dotclear export file"
        end

        def require_deps
          JekyllImport.require_with_fallback(%w(
            csv
            reverse_markdown
            yaml
          ))
        end

        def validate(opts)
          file_path = opts["datafile"]
          if file_path.nil? || file_path.empty?
            Jekyll.logger.abort_with "Import Error:", "Dotclear export file not found!"
          end

          file_path = File.expand_path(file_path)
          if File.open(file_path, "rb", &:readline).match?(%r!\A///DOTCLEAR\|!)
            @data = read_export(file_path)
            Jekyll.logger.info "Export File:", file_path
          else
            Jekyll.logger.abort_with "Import Error:", "#{file_path.inspect} is not a valid Dotclear export file!"
          end
        end

        def process(_opts)
          Jekyll.logger.info "Importing.."
          tags = register_post_tags
          posts = @data["post"]
          FileUtils.mkdir_p("_drafts") unless posts.empty?

          posts.each do |post|
            date, title, content, id = post.values_at("post_creadt", "post_title", "post_content", "post_id")
            path = File.join("_drafts", Date.parse(date).strftime("%Y-%m-%d-") + Jekyll::Utils.slugify(title) + ".md")
            front_matter_data = {
              "layout" => "post",
              "title"  => title,
              "date"   => date,
              "lang"   => post["post_lang"],
              "tags"   => tags[post["post_id"]],
            }.tap(&:compact!)

            # keep a record of existing URL for the post. Jekyll may or may not generate the same
            # URL depending on `permalink` settings in Jekyll configuration.
            front_matter_data["dotclear_post_url"] = post["post_url"]

            Jekyll.logger.info "Creating:", path
            File.write(path, "#{YAML.dump(front_matter_data)}---\n\n#{ReverseMarkdown.convert(content).strip}\n")
          end
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

          File.read(file).split("\n\n").each_with_object({}) do |section, data|
            next unless /^\[\b(?<key>.*)\b (?<header>.*)\]\s+(?<rows>.*)/m =~ section
            next if ignored_sections.include?(key)

            data[key] = rows.each_line.with_object([]) do |line, bucket|
              bucket << ::CSV.parse(line, headers: header).map(&:to_h)
            end.flatten

            data
          end
        end

        def register_post_tags
          @data["meta"].each_with_object({}) do |entry, tags|
            next unless entry["meta_type"] == "tag"

            tags[entry["post_id"]] ||= []
            tags[entry["post_id"]] << entry["meta_id"]
          end
        end
      end
    end
  end
end
