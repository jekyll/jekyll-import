# Modified by JoongSeob Vito Kim (https://github.com/dorajistyle) on 2014-11-18.
# Created by Kendall Buchanan (https://github.com/kendagriff) on 2011-12-22.
# Use at your own risk. The end.
#
# Usage:
#   (URL)
#   ruby -r 'jekyll/jekyll-import/rss' -e "JekyllImport::BLOGGER_DOCPAD.process(:source => 'http://yourdomain.com/your-favorite-feed.xml')"
#
#   (Local file)
#   ruby -r 'jekyll/jekyll-import/rss' -e "JekyllImport::BLOGGER_DOCPAD.process(:source => './somefile/on/your/computer.xml')"

module JekyllImport
  module Importers
    class BLOGGER_DOCPAD < Importer
      def self.specify_options(c)
        c.option 'source', '--source NAME', 'The RSS file or URL to import'
      end

      def self.validate(options)
        if options['source'].nil?
          abort "Missing mandatory option --source."
        end
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rss/1.0
          rss/2.0
          open-uri
          fileutils
          safe_yaml
        ])
      end

      # Process the import.
      #
      # source - a URL or a local file String.
      #
      # Returns nothing.
      def self.process(options)
        source = options.fetch('source')
	dest = "_posts"
        layout = "post"
        if !options['dest'].nil?
		dest = options.fetch("dest")
	end
        if !options['layout'].nil?
		layout = options.fetch("layout")
	end

        content = ""
        open(source) { |s| content = s.read }
        rss = ::RSS::Parser.parse(content, false)

        raise "There doesn't appear to be any RSS items at the source (#{source}) provided." unless rss

        rss.items.each do |item|
          formatted_date = item.date.strftime('%Y-%m-%d')
          post_name = item.title.split(%r{ |!|/|:|&|-|$|,}).map do |i|
            i.downcase if i != ''
          end.compact.join('-')
          name = "#{post_name}-#{formatted_date}".gsub('.','') 
	  categories = Array.new()
	  item.categories.each do |category|
            categories.push(category.content) 
	  end
          header = {
            'layout' => layout,
            'title' => item.title.tr("\n",""),
            'date' => formatted_date,
	    #'categories' => categories.join(","),
            'comments' => true,
            'adsense' => true,
	    'tags' => categories

	  }
          FileUtils.mkdir_p(dest)

          File.open(dest+"/#{name}.html", "w") do |f|
            f.puts header.to_yaml(options = {:line_width => -1}) 
            f.puts "---\n\n"
            f.puts item.description
          end
        end
      end
    end
  end
end
