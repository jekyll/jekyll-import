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

      def self.abort_on_invalid_migator
        msg = "You must specify a valid migrator. Valid choices:\n"
        IMPORTERS.keys.each do |k, v|
          msg += "* #{k}\n"
        end
        abort msg
      end

      def self.process(migrator, options)
        if IMPORTERS.keys.include?(migrator.to_sym)
          migrator = migrator.downcase

          p options

          cmd_options = []
          [ :file, :dbname, :user, :pass, :host, :site ].each do |p|
            cmd_options << "\"#{options[p]}\"" unless options[p].nil?
          end

          app_root = File.expand_path(
            File.join(File.dirname(__FILE__), '..', '..', '..')
          )

          require "jekyll/importers/#{migrator}"

          if Jekyll.const_defiend?(IMPORTERS[migrator.to_sym])
            puts 'Importing...'
            migrator_class = Jekyll.const_get(IMPORTERS[migrator.to_sym])
            migrator_class.process(*cmd_options)
            exit 0
          end
        else
          abort_on_invalid_migator
        end
      end
    end
  end
end
