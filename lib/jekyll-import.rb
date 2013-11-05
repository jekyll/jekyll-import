$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
require 'rubygems'
require 'jekyll/commands/import'
require 'jekyll/stevenson'

module JekyllImport
  VERSION = '0.1.0.beta4'

  def self.logger
    @logger ||= Jekyll::Stevenson.new
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
