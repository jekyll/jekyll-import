$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
require 'rubygems'
require 'jekyll/commands/import'
require 'jekyll/stevenson'

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

  def self.add_importer_commands(cmd)
    p Importer.subclasses
    p Importers.constants
    JekyllImport::Importer.subclasses.each do |importer|
      name = importer.to_s.downcase
      p name
      cmd.command(name.to_sym) do |c|
        c.syntax "jekyll import #{name} [options]"
        importer.specify_options(c)
        c.action do |args, options|
          importer.process(options)
        end
      end
    end
  end

  def self.require_with_fallback(gems)
    Array.wrap(gems).flatten.each do |gem|
      begin
        require gem
      rescue LoadError
        logger.abort_with "Whoops! Looks like you need to install '#{gem}' before you can use this migrator."
      end
    end
  end
end
