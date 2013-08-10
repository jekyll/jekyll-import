# Usage:
#   ruby -r '../jekyll-import/lib/jekyll/jekyll-import/behance.rb' -e 'JekyllImport::BehanceImport.process(user: "USERNAME", api_token: "API_TOKEN")'


require 'fileutils'
require 'safe_yaml'

require 'date'
require 'time'

begin 
  require 'behance'
rescue LoadError => e
  raise unless e.message =~ /behance/
  puts 'Please install behance before using the importer!'
end

module JekyllImport
  module BehanceImport
    def self.validate(options)
      if !options[:user]
        abort "Missing mandatory option --user."
      end
      if !options[:api_token]
        abort "Missing mandatory option --api_token."
      end
    end

    # Process the import.
    #
    # user - the behance user to retrieve projects (ID or username)
    # api_token - your developer API Token
    #
    # Returns nothing.
    def self.process(options)
      validate(options)

      user  = options[:user]
      token = options[:api_token]

      client    = Behance::Client.new(access_token: token)
      projects  = client.user_projects(user)

      projects.each do |project|

        details = client.project(project['id'])
        title   = project['name'].to_s
        formatted_date = Time.at(project['published_on']).to_date.to_s

        post_name = title.split(%r{ |!|/|:|&|-|$|,}).map do |character|
          character.downcase unless character.empty?
        end.compact.join('-')

        name = "#{formatted_date}-#{post_name}"

        header = {
          'layout' => 'post',
          'title' => title,
          'project' => details
        }

        FileUtils.mkdir_p("_posts")

        File.open("_posts/#{name}.md", "w") do |f|
          f.puts header.to_yaml
          f.puts "---\n\n"
          puts details['description']
          f.puts details['description']
        end
      end
    end
  end
end
