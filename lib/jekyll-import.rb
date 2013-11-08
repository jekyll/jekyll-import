$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
require 'rubygems'
require 'jekyll/commands/import'
require 'jekyll/stevenson'

module JekyllImport
  VERSION = '0.1.0.beta4'

  def self.logger
    @logger ||= Jekyll::Stevenson.new
  end

  def self.add_importer_commands(cmd)
    JekyllImport::Importer.subclasses.each do |importer|
      name = importer.to_s.downcase
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
