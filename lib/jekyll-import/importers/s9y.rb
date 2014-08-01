module JekyllImport
  module Importers
    class S9Y < Importer
      def self.specify_options(c)
        c.option 'source', '--source SOURCE', 'The URL of the S9Y RSS feed'
      end

      def self.validate(options)
        if options['source'].nil?
          abort "Missing mandatory option --source, e.g. --source \"http://blog.example.com/rss.php?version=2.0&all=1\""
        end
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          open-uri
          rss
          fileutils
          safe_yaml
        ])
      end

      def self.process(options)
        source = options.fetch('source')

        FileUtils.mkdir_p("_posts")

        text = ''
        open(source) { |line| text = line.read }
        rss = ::RSS::Parser.parse(text)

        rss.items.each do |item|
          post_url = item.link.match('.*(/archives/.*)')[1]
          categories = item.categories.collect { |c| c.content }
          content = item.content_encoded.strip
          date = item.date
          slug = item.link.match('.*/archives/[0-9]+-(.*)\.html')[1]
          name = "%02d-%02d-%02d-%s.markdown" % [date.year, date.month, date.day,
                                                 slug]

          data = {
            'layout' => 'post',
            'title' => item.title,
            'categories' => categories,
            'permalink' => post_url,
            's9y_link' => item.link,
            'date' => item.date,
          }.delete_if { |k,v| v.nil? || v == '' }.to_yaml

          # Write out the data and content to file
          File.open("_posts/#{name}", "w") do |f|
            f.puts data
            f.puts "---"
            f.puts content
          end
        end
      end
    end
  end
end
