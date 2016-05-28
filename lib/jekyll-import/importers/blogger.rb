module JekyllImport
  module Importers
    class Blogger < Importer
      def self.specify_options(c)
        c.option 'source', '--source NAME', 'The XML file (blog-MM-DD-YYYY.xml) path to import'
        c.option 'no-blogger-info', '--no-blogger-info', 'not to leave blogger-URL info (id and old URL) in the front matter (default: false)'
        c.option 'replace-internal-link', '--replace-internal-link', 'replace internal links using the post_url liquid tag. (default: false)'
        c.option 'comments', '--comments', 'import comments to _comments collection'
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
          open-uri
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
        listener.comments = options.fetch('comments', false),

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
        def initialize
          # use `extend` instead of `include` to use `require_deps` instead of `require`.
          extend REXML::StreamListener
          extend BloggerAtomStreamListenerMethods

          @leave_blogger_info = true
          @comments = false
        end
      end

      module BloggerAtomStreamListenerMethods
        attr_accessor :leave_blogger_info, :comments
        attr_reader :original_url_base

        def tag_start(tag, attrs)
          @tag_bread = [] unless @tag_bread
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
              elsif attrs['rel'] == 'replies' && attrs['type'] == 'text/html'
                unless @in_entry_elem[:meta][:original_url]
                  @in_entry_elem[:meta][:original_url] = attrs['href'].sub(/\#comment-form$/, '')
                end
              end
            end
          when 'media:thumbnail'
            if @in_entry_elem
              @in_entry_elem[:meta][:thumbnail] = attrs['url']
            end
          when 'thr:in-reply-to'
            if @in_entry_elem
              @in_entry_elem[:meta][:post_id] = attrs['ref']
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
            when 'app:draft'
              if @tag_bread[-2..-1] == %w[app:control app:draft]
                @in_entry_elem[:meta][:draft] = true if text == 'yes'
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
                target_dir = '_posts'
                target_dir = '_drafts' if @in_entry_elem[:meta][:draft]

                FileUtils.mkdir_p(target_dir)

                file_name = URI::decode("#{post_data[:filename]}.html")
                File.open(File.join(target_dir, file_name), 'w') do |f|
                  f.flock(File::LOCK_EX)

                  f << post_data[:header].to_yaml
                  f << "---\n\n"
                  f << post_data[:body]
                end
              end
            elsif @in_entry_elem[:meta][:kind] == 'comment' and @comments
              post_data = get_post_data_from_in_entry_elem_info

              if post_data
                target_dir = '_comments'

                FileUtils.mkdir_p(target_dir)

                file_name = URI::decode("#{post_data[:filename]}.html")
                File.open(File.join(target_dir, file_name), 'w') do |f|
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
            timestamp = Time.parse(@in_entry_elem[:meta][:published]).strftime('%Y-%m-%d')
            if @in_entry_elem[:meta][:original_url]
              original_uri = URI.parse(@in_entry_elem[:meta][:original_url])
              original_path = original_uri.path.to_s
              filename = "%s-%s" %
                [timestamp,
                 File.basename(original_path, File.extname(original_path))]

              @original_url_base = "#{original_uri.scheme}://#{original_uri.host}"
            elsif @in_entry_elem[:meta][:draft]
              # Drafts don't have published urls
              name = @in_entry_elem[:meta][:title]
              if name.nil?
                filename = timestamp
              else
                filename = "%s-%s" %
                  [timestamp,
                   CGI.escape(name.downcase).tr('+','-')]
              end
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
            header['blogger_orig_url'] = @in_entry_elem[:meta][:original_url] if @leave_blogger_info && @in_entry_elem[:meta][:original_url]

            body = @in_entry_elem[:body]

            # body escaping associated with liquid
            if body =~ /{{/
              body.gsub!(/{{/, '{{ "{{" }}')
            end
            if body =~ /{%/
              body.gsub!(/{%/, '{{ "{%" }}')
            end

            { :filename => filename, :header => header, :body => body }
          elsif @in_entry_elem[:meta][:kind] == 'comment'
            timestamp = Time.parse(@in_entry_elem[:meta][:published]).strftime('%Y-%m-%d')
            if @in_entry_elem[:meta][:original_url]
              if not @comment_seq
                @comment_seq = 1
              end

              original_uri = URI.parse(@in_entry_elem[:meta][:original_url])
              original_path = original_uri.path.to_s
              filename = "%s-%s-%s" %
                [timestamp,
                 File.basename(original_path, File.extname(original_path)),
                 @comment_seq]

              @comment_seq = @comment_seq + 1

              @original_url_base = "#{original_uri.scheme}://#{original_uri.host}"
            else
              raise 'Original URL is missing'
            end

            header = {
              'date' => @in_entry_elem[:meta][:published],
              'author' => @in_entry_elem[:meta][:author],
              'blogger_post_id' => @in_entry_elem[:meta][:post_id],
            }
            header['modified_time'] = @in_entry_elem[:meta][:updated] if @in_entry_elem[:meta][:updated] && @in_entry_elem[:meta][:updated] != @in_entry_elem[:meta][:published]
            header['thumbnail'] = @in_entry_elem[:meta][:thumbnail] if @in_entry_elem[:meta][:thumbnail]
            header['blogger_id'] = @in_entry_elem[:meta][:id] if @leave_blogger_info
            header['blogger_orig_url'] = @in_entry_elem[:meta][:original_url] if @leave_blogger_info && @in_entry_elem[:meta][:original_url]

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
