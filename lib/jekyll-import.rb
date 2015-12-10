$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
require 'rubygems'
require 'jekyll'
require 'jekyll/commands/import'
require 'colorator'

require 'jekyll-import/importer'
require 'jekyll-import/importers'
require 'jekyll-import/util'

module JekyllImport
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
        c.syntax "#{name} [options]"
        importer.specify_options(c)
        c.action do |_, options|
          importer.run(options)
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
        Jekyll.logger.error "Whoops! Looks like you need to install '#{gem}' before you can use this importer."
        Jekyll.logger.error ""
        Jekyll.logger.error "If you're using bundler:"
        Jekyll.logger.error "  1. Add 'gem \"#{gem}\"' to your Gemfile"
        Jekyll.logger.error "  2. Run 'bundle install'"
        Jekyll.logger.error ""
        Jekyll.logger.error "If you're not using bundler:"
        Jekyll.logger.abort_with "  1. Run 'gem install #{gem}'."
      end
    end
  end
end
