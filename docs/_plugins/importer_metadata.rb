# frozen_string_literal: true

require "jekyll-import"
require "mercenary"

module JekyllImport
  def self.require_with_fallback(gems)
    Array(gems).flatten
  end

  class Bridge
    # name     : Importer command name.
    # importer : `JekyllImport::Importer` subclass.
    # docs     : Array[`Jekyll::Document`].
    def initialize(name, importer, docs)
      @name     = name
      @cmd      = Mercenary::Command.new(name)
      @importer = importer
      @doc      = docs.find { |d| d.basename_without_ext == name }

      importer.specify_options(@cmd)
    end

    def inject_metadata!
      @doc.data["cmd_name"] = name
      @doc.data["cmd_deps"] = dependencies unless dependencies.empty?
      @doc.data["cmd_opts"] = options      unless options.empty?
    end

    private

    attr_reader :name

    # Gems assumed to be available either via Ruby Stdlib or prior installation.
    STDLIB = %w(csv date fileutils json net/http open-uri rss rubygems time uri yaml jekyll).freeze
    private_constant :STDLIB

    def dependencies
      @dependencies ||= begin
        deps = @importer.require_deps - STDLIB
        deps.map! { |dep| dep.start_with?("active_support") ? "activesupport" : dep.split("/")[0] }
        deps.uniq!
        deps.sort!
        deps
      end
    end

    def options
      @options ||= begin
        @cmd.options.map do |o|
          hsh = { "switch" => o.long }
          if %r!(?<desc>.+?)(?:\z| \(default: (?<default_value>.*)\))! =~ o.description
            hsh["desc"] = desc
            hsh["default_value"] = default_value
            hsh["mandatory"] = true unless default_value
          else
            hsh["desc"] = o.description
          end
          hsh.tap(&:compact!)
        end
      end
    end
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  importer_docs = site.collections["importers"].docs

  JekyllImport::Importer.subclasses.each do |klass|
    name = klass.name.split("::").last.downcase
    JekyllImport::Bridge.new(name, klass, importer_docs).inject_metadata!
  end
end
