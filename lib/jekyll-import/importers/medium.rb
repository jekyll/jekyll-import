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

      # Medium posts and associated metadata are exported as an RSS Feed. Hence invoke our RSS Importer to create the
      # Jekyll source directory.
      #
      # "Tags" attached to a Medium post are exported under the markup `<item><category>...</category></item>` in the
      # export feed. Therefore, configure the RSS Importer to always look for tags in the `<category></category>` field
      # of an RSS item.
      def self.process(options)
        Importers::RSS.process({
          "source"         => "https://medium.com/feed/@#{options.fetch("username")}",
          "render_audio"   => options.fetch("render_audio", false),
          "canonical_link" => options.fetch("canonical_link", false),
          "extract_tags"   => "category",
        })
      end
    end
  end
end
