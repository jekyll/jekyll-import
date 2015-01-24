$:.unshift File.expand_path("../../", File.dirname(__FILE__)) # load from jekyll-import/lib
require 'jekyll/command'
require 'jekyll-import'

module Jekyll
  module Commands
    class Import < Command

      IMPORTERS = {
        :blogger => 'Blogger',
        :behance => 'Behance',
        :csv => 'CSV',
        :drupal6 => 'Drupal6',
        :drupal7 => 'Drupal7',
        :enki => 'Enki',
        :joomla => 'Joomla',
        :joomla3 => 'Joomla3',
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
        :wordpressdotcom => 'WordpressDotCom'
      }

      class << self

        def init_with_program(prog)
          prog.command(:import) do |c|
            c.syntax 'import <platform> [options]'
            c.description 'Import your old blog to Jekyll'
            importers = JekyllImport.add_importer_commands(c)

            c.action do |args, options|
              if args.empty?
                Jekyll.logger.warn "You must specify an importer."
                Jekyll.logger.info "Valid options are:"
                importers.each { |i| Jekyll.logger.info "*", "#{i}" }
              end
            end
          end
        end

        def process(migrator, options)
          migrator = migrator.to_s.downcase

          if IMPORTERS.keys.include?(migrator.to_sym)
            if JekyllImport::Importers.const_defined?(IMPORTERS[migrator.to_sym])
              klass = JekyllImport::Importers.const_get(IMPORTERS[migrator.to_sym])
              if options.respond_to?(:__hash__)
                klass.run(options.__hash__)
              else
                klass.run(options)
              end
            end
          else
            abort_on_invalid_migrator(migrator)
          end
        end

        def abort_on_invalid_migrator(migrator)
          $stderr.puts "Sorry, '#{migrator}' isn't a valid migrator. Valid choices:"
          IMPORTERS.keys.each { |k| $stderr.puts "* #{k}" }
          raise RuntimeError.new("'#{migrator}' is not a valid migrator.")
        end

      end

    end
  end
end
