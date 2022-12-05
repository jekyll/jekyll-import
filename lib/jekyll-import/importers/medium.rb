# frozen_string_literal: true

module JekyllImport
  module Importers
    class Medium < Importer
      def self.specify_options(c)
        c.option "username",       "--username NAME",  "Medium username"
        c.option "canonical_link", "--canonical_link", "Copy original link as canonical_url to post (default: false)"
        c.option "render_audio",   "--render_audio",   "Render <audio> element in posts for the enclosure URLs (default: false)"
      end

      def self.validate(options)
        abort "Missing mandatory option --username." if options["username"].nil?
      end

      def self.require_deps
        Importers::RSS.require_deps
      end

      def self.process(options)
        Importers::RSS.process({
          "source"         => "https://medium.com/feed/@#{options.fetch("username")}",
          "render_audio"   => options.fetch("render_audio", false),
          "canonical_link" => options.fetch("canonical_link", false),
          # When a user publish posts on Medium, most of the time it contains tags which helps others to search the post.
          # When we export RSS feed from Medium, it uses `category` subfield on the RSS <item> to provide existing tags.
          # With the following config, we will add existing tags from Medium post to front matter so that similar tags
          # can be visible on website.
          "extract_tags"   => "category",
        })
      end
    end
  end
end
