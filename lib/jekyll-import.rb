$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed
require 'rubygems'
require 'jekyll/commands/import'

module JekyllImport
  VERSION = '0.1.0.beta2'
end
