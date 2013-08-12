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

      abort "'#{file}' not found." unless File.file?(file)

      input = File.read(file)
      entries = input.split("\n\n");

      entries.each do |entry|
        content = entry.split("\n")
        dateline = content[0]
        body = content[1]
        date = Time.parse(content[0, date_length-1].to_s)
        title = dateline[date_length+1, dateline.length]
        slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

        data = {
          'layout'        => layout.to_s,
          'title'         => title.to_s,
          'date'          => date.strftime(time_format).to_s
        }.to_yaml

        filename = date.strftime("%Y-%m-%d").to_s + "-#{slug}.#{extension}"

        File.open("_posts/#{filename}", "w") do |f|
          f.puts data
          f.puts "---"
          f.puts body
        end
      end
    end
  end
end
