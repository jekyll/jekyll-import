# Author: Aniket Pant <me@aniketpant.com

require 'time'
require 'rubygems'
require 'safe_yaml'

module JekyllImport
  module Jrnl
    # Reads a jrnl file and creates a new post for each entry
    # The following overrides are available:
    # :file         path to input file
    # :time_format  the format used by the jrnl configuration
    # :extension    the extension format of the output files
    # :layout       explicitly set the layout of the output
    def self.process(options)
      file = options[:file] || "~/journal.txt"
      time_format = options[:time_format] || "%Y-%m-%d %H:%M"
      extension = options[:extension] || "md"
      layout = options[:layout] || "post"

      date_length = Time.now().strftime(time_format).length

      # convert relative to absolute if needed
      file = File.expand_path(file)

      abort "The jrnl file was not found. Please make sure '#{file}' exists. You can specify a different file using the --file switch." unless File.file?(file)

      input = File.read(file)
      entries = input.split("\n\n");

      entries.each do |entry|
        # split dateline and body
        content = entry.split("\n")

        # strip dateline from jrnl entry
        dateline = content[0]

        # strip body from jrnl entry
        body = content[1]

        # strip timestamp from the dateline
        date = Time.parse(content[0, date_length - 1].to_s)

        # strip title from the dateline
        title = dateline[date_length + 1, dateline.length]

        # generate slug
        slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

        # generate filename
        filename = "#{date.strftime("%Y-%m-%d")}-#{slug}.#{extension}"

        meta = prepare_data(layout, title, date) # prepare YAML meta data
        write_file(filename, meta, body) # write to file
      end
    end

    # Prepare YAML meta data
    #
    # layout  - name of the layout
    # title   - title of the entry
    # date    - date of entry creation
    #
    # Examples
    #
    #   prepare_data("post", "Entry 1", "2013-01-01 13:00")
    #   # => "---\nlayout: post\ntitle: Entry 1\ndate: 2013-01-01 13:00\n"
    #
    # Returns array converted to YAML
    def self.prepare_data(layout, title, date)
      data = {
        'layout'        => layout.to_s,
        'title'         => title.to_s,
        'date'          => date.strftime("%Y-%m-%d %H:%M %z").to_s
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
    #   write_file("2013-01-01-entry-1.md", "---\nlayout: post\ntitle: Entry 1\ndate: 2013-01-01 13:00\n", "This is the first entry for my new journl")
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
