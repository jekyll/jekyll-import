$:.unshift File.expand_path("../../", File.dirname(__FILE__)) # load from jekyll-import/lib

module Jekyll
  module Commands
    class Import < Command
      IMPORTERS = {
        :csv => 'CSV',
        :drupal => 'Drupal',
        :enki => 'Enki',
        :mephisto => 'Mephisto',
        :mt => 'MT',
        :posterous => 'Posterous',
        :textpattern => 'TextPattern',
        :tumblr => 'Tumblr',
        :typo => 'Typo',
        :wordpressdotcom => 'WordpressDotCom',
        :wordpress => 'WordPress'
      }

      def self.process(migrator, options)
        abort 'missing argument. Please specify a migrator' if migrator.nil?
        migrator = migrator.downcase

        cmd_options = []
        [ :file, :dbname, :user, :pass, :host, :site ].each do |p|
          cmd_options << "\"#{options[p]}\"" unless options[p].nil?
        end


        if IMPORTERS.keys.include?(migrator)
          app_root = File.expand_path(
            File.join(File.dirname(__FILE__), '..', '..', '..')
          )

          require "jekyll/migrators/#{migrator}"

          if Jekyll.const_defiend?(IMPORTERS[migrator.to_sym])
            puts 'Importing...'
            migrator_class = Jekyll.const_get(IMPORTERS[migrator.to_sym])
            migrator_class.process(*cmd_options)
            exit 0
          end
        end

        abort "Invalid migrator: '#{migrator.to_sym}'. Please specify a valid migrator."
      end
    end
  end
end
