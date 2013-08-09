# Usage:
#   ruby -r 'jekyll/jekyll-import/behance' -e "JekyllImport::BehanceImport.process(user: "USERNAME", api_token: "API_KEY")'

require 'fileutils'
require 'safe_yaml'

require 'date'
require 'time'
require 'behance'

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
    # source - a URL or a local file String.
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
        formatted_date = Time.at(project['published_on']).to_datetime.to_s

        post_name = title.split(%r{ |!|/|:|&|-|$|,}).map do |i|
          i.downcase if i != ''
        end.compact.join('-')

        name = "#{formatted_date}-#{post_name}"

        header = {
          'layout' => 'post',
          'title' => title,
          'project' => details
        }

        FileUtils.mkdir_p("_posts")

        File.open("_posts/#{name}.html", "w") do |f|
          f.puts header.to_yaml
          f.puts "---\n\n"
          # Need to include Behance modules as content
        end
      end
    end
  end
end
