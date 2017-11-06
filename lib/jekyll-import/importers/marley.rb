module JekyllImport
  module Importers
    class Marley < Importer
      def self.validate(options)
        if options["marley_data_dir"].nil?
          Jekyll.logger.abort_with "Missing mandatory option --marley_data_dir."
        else
          unless File.directory?(options["marley_data_dir"])
            raise ArgumentError, "marley dir '#{options["marley_data_dir"]}' not found"
          end
        end
      end

      def self.regexp
        { :id              => %r!^\d{0,4}-{0,1}(.*)$!,
          :title           => %r!^#\s*(.*)\s+$!,
          :title_with_date => %r!^#\s*(.*)\s+\(([0-9\/]+)\)$!,
          :published_on    => %r!.*\s+\(([0-9\/]+)\)$!,
          :perex           => %r!^([^\#\n]+\n)$!,
          :meta            => %r!^\{\{\n(.*)\}\}\n$!mi, } # Multiline Regexp
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          fileutils
          safe_yaml
        ))
      end

      def self.specify_options(c)
        c.option "marley_data_dir", "--marley_data_dir DIR", "The dir containing your marley data"
      end

      def self.process(options)
        marley_data_dir = options.fetch("marley_data_dir")

        FileUtils.mkdir_p "_posts"

        posts = 0
        Dir["#{marley_data_dir}/**/*.txt"].each do |f|
          next unless File.exist?(f)

          # copied over from marley's app/lib/post.rb
          file_content  = File.read(f)
          meta_content  = file_content.slice!(self.regexp[:meta])
          body          = file_content.sub(self.regexp[:title], "").sub(self.regexp[:perex], "").strip

          title = file_content.scan(self.regexp[:title]).first.to_s.strip
          prerex = file_content.scan(self.regexp[:perex]).first.to_s.strip
          published_on = DateTime.parse(post[:published_on]) rescue File.mtime(File.dirname(f))
          meta          = meta_content ? YAML.safe_load(meta_content.scan(self.regexp[:meta]).to_s) : {}
          meta["title"] = title
          meta["layout"] = "post"

          formatted_date = published_on.strftime("%Y-%m-%d")
          post_name = File.dirname(f).split(%r!/!).last.gsub(%r!\A\d+-!, "")

          name = "#{formatted_date}-#{post_name}"
          File.open("_posts/#{name}.markdown", "w") do |f|
            f.puts meta.to_yaml
            f.puts "---\n"
            f.puts "\n#{prerex}\n\n" if prerex
            f.puts body
          end
          posts += 1
        end
        "Created #{posts} posts!"
      end
    end
  end
end
