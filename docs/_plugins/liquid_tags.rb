# frozen_string_literal: true

require "jekyll-import"

module JekyllImport
  module Docs
    class OptgroupTag < Liquid::Tag
      include Jekyll::Filters::URLFilters

      def initialize(tag_name, markup, options)
        raise(SyntaxError, "Invalid syntax in #{tag_name} tag") unless markup.strip =~ %r!\s*(.*) from (.*)!

        @captures = Regexp.last_match.captures.map { |e| Liquid::Expression.parse(e) }
      end

      def render(context)
        @context = context # set `@context` for Jekyll::Filters::URLFilters
        label, items = @captures.map { |e| context.evaluate(e) }
        render_elements(label, items)
      end

      private

      def render_elements(label, items)
        <<~HTML
          <optgroup label="#{label}">
            #{render_items(items)}
          </optgroup>
        HTML
      end

      def render_items(items)
        items.map do |entry|
          %(<option value="#{relative_url(entry.url)}">#{entry.data["title"]}</option>)
        end.join("\n  ")
      end
    end

    class ListgroupTag < OptgroupTag
      private

      def render_elements(label, items)
        <<~HTML
          <h4>#{label}</h4>
          <ul>
            #{render_items(items)}
          </ul>
        HTML
      end

      def render_items(items)
        page = @context.registers[:page]
        page_url = page ? page["url"] : ""

        items.map do |entry|
          res = +"<li"
          res << %( class="current") if page_url == entry.url
          res << %(><a href="#{relative_url(entry.url)}">#{entry.data["title"]}</a></li>)
          res
        end.join("\n  ")
      end
    end

    Liquid::Template.register_tag "optgroup", OptgroupTag
    Liquid::Template.register_tag "listgroup", ListgroupTag
  end
end
