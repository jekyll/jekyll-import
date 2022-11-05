# frozen_string_literal: true

module JekyllImport
  module Importers
    class Medium < Importer
      def self.specify_options(c)
        c.option "username", "--username NAME", "Medium username"
        c.option "canonical_link", "--canonical_link true", "Add medium canonical link to each post"
        c.option "render_audio", "--render_audio", "Render <audio> element as necessary"
      end

      def self.validate(options)
        abort "Missing mandatory option --username." if options["username"].nil?
      end

      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          rss
        ))
      end

      # Process the import.
      #
      # username - Medium username.
      #
      # Returns nothing.
      def self.process(options)
        RSS.process({
                      "source" => "https://medium.com/feed/@#{options.fetch("username")}",
                      "render_audio" => options.fetch("render_audio", false),
                      "canonical_link" => options.fetch("canonical_link", true),
                      "extract_tags" => "category",
                    })
      end
    end
  end
end
