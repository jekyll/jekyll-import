require "bundler/setup"
require "jekyll-import"
require "mercenary"

# The out-of-box Help output contains noise from * injected default options* such as
# `--help`, `--verbose`, etc in addition to options injected options from the `jekyll`
# executable.
# Therefore create a custom `Mercenary::Command` instances along with some monkey-patches
# to prettify output.

module Mercenary
  class Option
    def to_s(justify_length=15)
      "#{short.to_s.rjust(10)} #{long.ljust(justify_length)}  #{description}"
    end
  end

  class Presenter
    def command_options_presentation
      c_opts = command.options
      return nil if c_opts.empty?

      justify_length = c_opts.map { |o| o.long.length }.max
      c_opts.map { |o| o.to_s(justify_length) }.join("\n")
    end
  end
end

prog = Mercenary::Program.new(:jekyll).command(:import, &:itself)

JekyllImport::Importer.subclasses.each do |importer|
  puts "\n\n"
  name = importer.to_s.split("::").last.downcase
  cmd  = Mercenary::Command.new(name, prog)
  cmd.syntax "#{name} [options]"
  importer.specify_options(cmd)
  puts cmd
end
