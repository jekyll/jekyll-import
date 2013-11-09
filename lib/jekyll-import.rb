$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
require 'rubygems'
require 'jekyll/commands/import'
require 'jekyll/stevenson'
require 'colorator'

def require_all(dir)
  Dir[File.expand_path(File.join(dir, '*.rb'), File.dirname(__FILE__))].each do |f|
    require f
  end
end

require 'jekyll-import/importer'
require 'jekyll-import/importers'
#require_all 'jekyll-import/importers'

module JekyllImport
  VERSION = '0.1.0.beta4'

  def self.logger
    @logger ||= Jekyll::Stevenson.new
  end

  # Public: Add the subcommands for each importer
  #
  # cmd - the instance of Mercenary::Command from the
  #
  # Returns a list of valid subcommands
  def self.add_importer_commands(cmd)
    commands = []
    JekyllImport::Importer.subclasses.each do |importer|
      name = importer.to_s.split("::").last.downcase
      commands << name
      cmd.command(name.to_sym) do |c|
        c.syntax "jekyll import #{name} [options]"
        importer.specify_options(c)
        c.action do |args, options|
          importer.require_deps
          importer.validate(options) if importer.respond_to?(:validate)
          importer.process(options)
        end
      end
    end
    commands
  end

  def self.require_with_fallback(gems)
    Array[gems].flatten.each do |gem|
      begin
        require gem
      rescue LoadError
        logger.abort_with "Whoops! Looks like you need to install '#{gem}' before you can use this migrator."
      end
    end
  end
end
