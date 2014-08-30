require 'rexml/streamlistener'

module JekyllImport
  module Importers
    class Blogger < Importer
      def self.specify_options(c)
        c.option 'source', '--source NAME', 'The XML file (blog-MM-DD-YYYY.xml) path to import'
        c.option 'no-blogger-info', '--no-blogger-info', 'Leave blogger-URL info (id and old URL.) as YAML data (default: false)'
        c.option 'replace-internal-link', '--replace-internal-link', 'Whether to replace internal links with the post_url liquid codes (default: false)'
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
      # source::                a local file String (or IO object for internal use purpose)..
      # no-blogger-info::       a boolean if not leave blogger info (id and original URL).
      # replace-internal-link:: a boolean if replace internal link
      #
      # Returns nothing.
      def self.process(options)
        source = options.fetch('source')

        listener = BloggerAtomStreamListener.new

        listener.leave_blogger_info = ! options.fetch('no-blogger-info', false),

        File.open(source, 'r') do |f|
          f.flock(File::LOCK_SH)
          REXML::Parsers::StreamParser.new(f, listener).parse()
        end

        options['original-url-base'] = listener.original_url_base

        postprocess(options)
      end

      # Post-process after import.
      #
      # replace-internal-link:: a boolean if replace internal link
      #
      # Returns nothing.
      def self.postprocess(options)
        # Replace internal link URL
        if options.fetch('replace-internal-link', false)
          original_url_base = options.fetch('original-url-base', nil)
          if original_url_base
            orig_url_pattern = Regexp.new(" href=([\"\'])(?:#{Regexp.escape(original_url_base)})?/([0-9]{4})/([0-9]{2})/([^\"\']+\.html)\\1")

            Dir.glob('_posts/*.*') do |filename|
              body = nil
              File.open(filename, 'r') do |f|
                f.flock(File::LOCK_SH)
                body = f.read
              end

              body.gsub!(orig_url_pattern) do
                # for post_url
                quote = $1
                post_file = Dir.glob("_posts/#{$2}-#{$3}-*-#{$4.to_s.tr('/', '-')}").first
                raise "Could not found: _posts/#{$2}-#{$3}-*-#{$4.to_s.tr('/', '-')}" if post_file.nil?
                " href=#{quote}{{ site.baseurl }}{% post_url #{File.basename(post_file, '.html')} %}#{quote}"
              end

              File.open(filename, 'w') do |f|
                f.flock(File::LOCK_EX)
                f << body
              end
            end
          end
        end
      end

      class BloggerAtomStreamListener
        include REXML::StreamListener
      
        def initialize
          @tag_bread = []
      
          @in_entry_elem = nil
          @in_category_elem_attrs = nil

          # options
          @leave_blogger_info = true
        end
        attr_accessor :leave_blogger_info
        attr_reader :original_url_base
      
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
          when 'media:thumbnail'
            if @in_entry_elem
              @in_entry_elem[:meta][:thumbnail] = attrs['url']
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
            when 'name'
              if @tag_bread[-2..-1] == %w[author name]
                @in_entry_elem[:meta][:author] = text
              end
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
      
                File.open("_posts/#{post_data[:filename]}.html", 'w') do |f|
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

              @original_url_base = "#{original_uri.scheme}://#{original_uri.host}"
            else
              raise 'Original URL is missing'
            end
        
            header = {
              'layout' => 'post',
              'title' => @in_entry_elem[:meta][:title],
              'date' => @in_entry_elem[:meta][:published],
              'author' => @in_entry_elem[:meta][:author],
              'tags' => @in_entry_elem[:meta][:category],
            }
            header['modified_time'] = @in_entry_elem[:meta][:updated] if @in_entry_elem[:meta][:updated] && @in_entry_elem[:meta][:updated] != @in_entry_elem[:meta][:published]
            header['thumbnail'] = @in_entry_elem[:meta][:thumbnail] if @in_entry_elem[:meta][:thumbnail]
            header['blogger_id'] = @in_entry_elem[:meta][:id] if @leave_blogger_info
            header['blogger_orig_url'] = @in_entry_elem[:meta][:original_url] if @leave_blogger_info
        
            body = @in_entry_elem[:body]

            # body escaping associated with liquid
            if body =~ /{{/
              body.gsub!(/{{/, '{{ "{{" }}')
            end
            if body =~ /{%/
              body.gsub!(/{%/, '{{ "{%" }}')
            end
  
            { :filename => filename, :header => header, :body => body }
          else
            nil
          end
        end

      end

    end
  end
end

if $0 == __FILE__
  JekyllImport::Importers::Blogger::process(
    'source' => ARGV.first,
    'no-blogger-info' => false,
    'replace-internal-link' => true,
  )
end

# vim: filetype=ruby fileencoding=UTF-8 shiftwidth=2 tabstop=2 autoindent expandtab
