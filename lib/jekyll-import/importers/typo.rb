module JekyllImport
  module Importers
    class Typo < Importer
      # This SQL *should* work for both MySQL and PostgreSQL.
      SQL = <<-EOS
      SELECT c.id id,
             c.title title,
             c.permalink slug,
             c.body body,
             c.extended extended,
             c.published_at date,
             c.state state,
             c.keywords keywords,
             COALESCE(tf.name, 'html') filter
        FROM contents c
             LEFT OUTER JOIN text_filters tf
                          ON c.text_filter_id = tf.id
      EOS

      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          rubygems
          sequel
          fileutils
          safe_yaml
        ])
      end

      def self.specify_options(c)
        c.option 'server', '--server TYPE', 'Server type ("mysql" or "postgres")'
        c.option 'dbname', '--dbname DB', 'Database name'
        c.option 'user', '--user USER', 'Database user name'
        c.option 'password', '--password PW', "Database user's password (default: '')"
        c.option 'host', '--host HOST', 'Database host name'
      end

      def self.process(options)
        server = options.fetch('server')
        dbname = options.fetch('dbname')
        user   = options.fetch('user')
        pass   = options.fetch('password', '')
        host   = options.fetch('host', "localhost")

        FileUtils.mkdir_p '_posts'
        case server.intern
        when :postgres
          db = Sequel.postgres(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')
        when :mysql
          db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')
        else
          raise "Unknown database server '#{server}'"
        end
        db[SQL].each do |post|
          next unless post[:state] =~ /published/i

          if post[:slug] == nil
            post[:slug] = "no slug"
          end

          if post[:extended]
            post[:body] << "\n<!-- more -->\n"
            post[:body] << post[:extended]
          end

          name = [ sprintf("%.04d", post[:date].year),
                   sprintf("%.02d", post[:date].month),
                   sprintf("%.02d", post[:date].day),
                   post[:slug].strip ].join('-')

          # Can have more than one text filter in this field, but we just want
          # the first one for this.
          name += '.' + post[:filter].split(' ')[0]

          File.open("_posts/#{name}", 'w') do |f|
            f.puts({ 'layout'   => 'post',
                     'title'    => (post[:title] and post[:title].to_s.force_encoding('UTF-8')),
                     'tags'     => (post[:keywords] and post[:keywords].to_s.force_encoding('UTF-8')),
                     'typo_id'  => post[:id]
                   }.delete_if { |k, v| v.nil? || v == '' }.to_yaml)
            f.puts '---'
            f.puts post[:body].delete("\r")
          end
        end
      end

    end
  end
end
