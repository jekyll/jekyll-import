module JekyllImport
    module Importers
    class Enki < Importer
      SQL = <<-EOS
        SELECT p.id,
               p.title,
               p.slug,
               p.body,
               p.published_at as date,
               p.cached_tag_list as tags
        FROM posts p
EOS

      def self.validate(options)
        %w[dbname user].each do |option|
          if options[option].nil?
            abort "Missing mandatory option --#{option}."
          end
        end
      end

      def self.specify_options(c)
        c.option 'dbname', '--dbname', 'Database name'
        c.option 'user', '--user', 'Database name'
        c.option 'password', '--password', 'Database name (default: "")'
        c.option 'host', '--host', 'Database name'
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          sequel
          fileutils
          pg
          yaml
        ])
      end

      # Just working with postgres, but can be easily adapted
      # to work with both mysql and postgres.
      def self.process(options)
        dbname = options.fetch('dbname')
        user   = options.fetch('user')
        pass   = options.fetch('password', "")
        host   = options.fetch('host', "localhost")

        FileUtils.mkdir_p('_posts')
        db = Sequel.postgres(:database => dbname,
                             :user => user,
                             :password => pass,
                             :host => host,
                             :encoding => 'utf8')

        db[SQL].each do |post|
          name = [ sprintf("%.04d", post[:date].year),
                   sprintf("%.02d", post[:date].month),
                   sprintf("%.02d", post[:date].day),
                   post[:slug].strip ].join('-')
          name += '.textile'

          File.open("_posts/#{name}", 'w') do |f|
            f.puts({ 'layout'   => 'post',
                     'title'    => post[:title].to_s,
                     'enki_id'  => post[:id],
                     'categories'  => post[:tags]
                   }.delete_if { |k, v| v.nil? || v == '' }.to_yaml)
            f.puts '---'
            f.puts post[:body].delete("\r")
          end
        end
      end
    end
  end
end
