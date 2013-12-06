$:.unshift File.expand_path("../../", File.dirname(__FILE__)) # load from jekyll-import/lib
require 'jekyll/command'
require 'jekyll-import'

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
        :ghost => 'Ghost',
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
        :wordpressdotcom => 'WordpressDotCom',
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

          if JekyllImport::Importers.const_defined?(IMPORTERS[migrator.to_sym])
            klass = JekyllImport::Importers.const_get(IMPORTERS[migrator.to_sym])
            klass.run(options.__hash__)
          end
        else
          abort_on_invalid_migrator(migrator)
        end
      end
    end
  end
end
