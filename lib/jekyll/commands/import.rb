$:.unshift File.expand_path("../../", File.dirname(__FILE__)) # load from jekyll-import/lib
require 'jekyll/command'

module Jekyll
  module Commands
    class Import < Command
      IMPORTERS = {
        :csv => 'CSV',
        :drupal6 => 'Drupal6',
        :drupal7 => 'Drupal7',
        :enki => 'Enki',
        :joomla => 'Joomla',
        :jrnl => 'Jrnl',
        :google_reader => 'GoogleReader',
        :marley => 'Marley',
        :mephisto => 'Mephisto',
        :mt => 'MT',
        :posterous => 'Posterous',
        :rss => 'RSS',
        :s9y => 'S9Y',
        :textpattern => 'TextPattern',
        :tumblr => 'Tumblr',
        :typo => 'Typo',
        :wordpress => 'WordPress',
        :wordpressdotcom => 'WordpressDotCom'
      }

      def self.abort_on_invalid_migrator(migrator)
        msg = "Sorry, '#{migrator}' isn't a valid migrator. Valid choices:\n"
        IMPORTERS.keys.each do |k, v|
          msg += "* #{k}\n"
        end
        abort msg
      end

      def self.process(migrator, options)
        if IMPORTERS.keys.include?(migrator.to_s.to_sym)
          migrator = migrator.to_s.downcase

          require File.join(File.dirname(__FILE__), "..", "jekyll-import", "#{migrator}.rb")

          if JekyllImport.const_defined?(IMPORTERS[migrator.to_sym])
            klass = JekyllImport.const_get(IMPORTERS[migrator.to_sym])
            klass.validate(options.__hash__) if klass.respond_to?(:validate)
            puts 'Importing...'
            klass.process(options.__hash__)
          end
        else
          abort_on_invalid_migrator(migrator)
        end
      end
    end
  end
end
