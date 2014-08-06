# Created by @cat_in_136.
# Use at your own risk.
#
# Usage:
#   ruby -r 'jekyll/jekyll-import/blogger' -e "JekyllImport::Blogger.process(:source => '/path/to/blog-MM-DD-YYYY.xml')"
#

require 'rexml/streamlistener'

module JekyllImport
  module Importers
    class Blogger < Importer
      def self.specify_options(c)
        c.option 'source', '--source NAME', 'The XML file (blog-MM-DD-YYYY.xml) path to import'
      end

      def self.validate(options)
        if options['source'].nil?
          raise 'Missing mandatory option: --source'
        elsif not File.exist?(options['source'])
          raise Errno::ENOENT, "File not found: #{options['source']}"
        end
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rexml/document
          rexml/streamlistener
          rexml/parsers/streamparser
          uri
          time
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

        listener = BloggerAtomStreamListener.new
        File.open(source, 'r') do |f|
          f.flock(File::LOCK_SH)
          REXML::Parsers::StreamParser.new(f, listener).parse()
        end
      end

      class BloggerAtomStreamListener
        include REXML::StreamListener
      
        def initialize
          @tag_bread = []
      
          @in_entry_elem = nil
          @in_category_elem_attrs = nil
        end
      
        def tag_start(tag, attrs)
          @tag_bread.push(tag)
      
          case tag
          when 'entry'
            raise 'nest entry element' if @in_entry_elem
            @in_entry_elem = {:meta => {}, :body => nil}
          when 'title'
            if @in_entry_elem
              raise 'only <title type="text"></title> is supported' if attrs['type'] != 'text'
            end
          when 'category'
            if @in_entry_elem
              if attrs['scheme'] == 'http://www.blogger.com/atom/ns#'
                @in_entry_elem[:meta][:category] = [] unless @in_entry_elem[:meta][:category]
                @in_entry_elem[:meta][:category] << attrs['term']
              elsif attrs['scheme'] == 'http://schemas.google.com/g/2005#kind'
                kind = attrs['term']
                kind.sub!(Regexp.new("^http://schemas\\.google\\.com/blogger/2008/kind\\#"), '')
                @in_entry_elem[:meta][:kind] = kind
              end
            end
          when 'content'
            if @in_entry_elem
              @in_entry_elem[:meta][:content_type] = attrs['type']
            end
          when 'link'
            if @in_entry_elem
              if attrs['rel'] == 'alternate' && attrs['type'] == 'text/html'
                @in_entry_elem[:meta][:original_url] = attrs['href']
              end
            end
          end
        end
      
        def text(text)
          if @in_entry_elem
            case @tag_bread.last
            when 'id'
              @in_entry_elem[:meta][:id] = text
            when 'published'
              @in_entry_elem[:meta][:published] = text
            when 'updated'
              @in_entry_elem[:meta][:updated] = text
            when 'title'
              @in_entry_elem[:meta][:title] = text
            when 'content'
              @in_entry_elem[:body] = text
            end
          end
        end 
      
        def tag_end(tag)
          case tag
          when 'entry'
            raise 'nest entry element' unless @in_entry_elem
      
            if @in_entry_elem[:meta][:kind] == 'post'
              post_data = get_post_data_from_in_entry_elem_info

              if post_data
                FileUtils.mkdir_p('_posts')
      
                File.open("_posts/#{filename}.html", 'w') do |f|
                  f.flock(File::LOCK_EX)
      
                  f << post_data[:header].to_yaml
                  f << "---\n\n"
                  f << post_data[:body]
                end
              end
            end
      
            @in_entry_elem = nil
          end
      
          @tag_bread.pop
        end

        def get_post_data_from_in_entry_elem_info
          if (@in_entry_elem.nil? || ! @in_entry_elem.has_key?(:meta) || ! @in_entry_elem[:meta].has_key?(:kind))
            nil
          elsif @in_entry_elem[:meta][:kind] == 'post'
            if @in_entry_elem[:meta][:original_url]
              original_uri = URI.parse(@in_entry_elem[:meta][:original_url])
              original_path = original_uri.path.to_s
              filename = "%s-%s" %
                [Time.parse(@in_entry_elem[:meta][:published]).strftime('%Y-%m-%d'),
                 File.basename(original_path, File.extname(original_path))]
            else
              raise 'Original URL is missing'
            end
        
            header = {
              'layout' => 'post',
              'title' => @in_entry_elem[:meta][:title],
              'date' => @in_entry_elem[:meta][:published],
              'tags' => @in_entry_elem[:meta][:category],
            }
            header['blogger_id'] = @in_entry_elem[:meta][:id]
            header['blogger_orig_url'] = @in_entry_elem[:meta][:original_url]
        
            body = @in_entry_elem[:body]
            # TODO text replacement
  
            { :header => header, :body => body }
          else
            nil
          end
        end

      end

    end
  end
end

if $0 == __FILE__
  listener = JekyllImport::Importers::Blogger::BloggerAtomStreamListener.new
  REXML::Parsers::StreamParser.new(ARGF, listener).parse()
end

# vim: filetype=ruby fileencoding=UTF-8 shiftwidth=2 tabstop=2 autoindent expandtab
