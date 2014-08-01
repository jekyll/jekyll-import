module JekyllImport
  module Importers
    class Jrnl < Importer

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          time
          rubygems
          safe_yaml
        ])
      end

      def self.specify_options(c)
        c.option 'file', '--file FILENAME', 'Journal file (default: "~/journal.txt")'
        c.option 'time_format', '--time_format FORMAT', 'Time format of your journal (default: "%Y-%m-%d %H:%M")'
        c.option 'extension', '--extension EXT', 'Output extension (default: "md")'
        c.option 'layout', '--layout NAME', 'Output post layout (default: "post")'
      end

      # Reads a jrnl file and creates a new post for each entry
      # The following overrides are available:
      # :file         path to input file
      # :time_format  the format used by the jrnl configuration
      # :extension    the extension format of the output files
      # :layout       explicitly set the layout of the output
      def self.process(options)
        file        = options.fetch('file', "~/journal.txt")
        time_format = options.fetch('time_format', "%Y-%m-%d %H:%M")
        extension   = options.fetch('extension', "md")
        layout      = options.fetch('layout', "post")

        date_length = Time.now.strftime(time_format).length

        # convert relative to absolute if needed
        file = File.expand_path(file)

        abort "The jrnl file was not found. Please make sure '#{file}' exists. You can specify a different file using the --file switch." unless File.file?(file)

        input = File.read(file)
        entries = input.split("\n\n");

        entries.each do |entry|
          # split dateline and body
          # content[0] has the date and title
          # content[1] has the post body
          content = entry.split("\n")

          body = get_post_content(content)
          date = get_date(content[0], date_length)
          title = get_title(content[0], date_length)
          slug = create_slug(title)
          filename = create_filename(date, slug, extension)
          meta = create_meta(layout, title, date) # prepare YAML meta data

          write_file(filename, meta, body) # write to file
        end
      end

      # strip body from jrnl entry
      def self.get_post_content(content)
        return content[1]
      end

      # strip timestamp from the dateline
      def self.get_date(content, offset)
        return content[0, offset]
      end

      # strip title from the dateline
      def self.get_title(content, offset)
        return content[offset + 1, content.length]
      end

      # generate slug
      def self.create_slug(title)
        return title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      end

      # generate filename
      def self.create_filename(date, slug, extension)
        return "#{Time.parse(date).strftime("%Y-%m-%d")}-#{slug}.#{extension}"
      end

      # Prepare YAML meta data
      #
      # layout  - name of the layout
      # title   - title of the entry
      # date    - date of entry creation
      #
      # Examples
      #
      #   create_meta("post", "Entry 1", "2013-01-01 13:00")
      #   # => "---\nlayout: post\ntitle: Entry 1\ndate: 2013-01-01 13:00\n"
      #
      # Returns array converted to YAML
      def self.create_meta(layout, title, date)
        data = {
          'layout'        => layout,
          'title'         => title,
          'date'          => Time.parse(date).strftime("%Y-%m-%d %H:%M %z")
        }.to_yaml
        return data;
      end

      # Writes given data to file
      #
      # filename    - name of the output file
      # meta        - YAML header data
      # body        - jrnl entry content
      #
      # Examples
      #
      #   write_file("2013-01-01-entry-1.md", "---\nlayout: post\ntitle: Entry 1\ndate: 2013-01-01 13:00\n", "This is the first entry for my new journal")
      #
      # Writes file to _posts/filename
      def self.write_file(filename, meta, body)
        File.open("_posts/#{filename}", "w") do |f|
          f.puts meta
          f.puts "---\n\n"
          f.puts body
        end
      end
    end
  end
end
