# frozen_string_literal: true

require "jekyll-import"
require "mercenary"

module JekyllImport
  def self.require_with_fallback(gems)
    Array(gems).flatten
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  # available as part of Ruby Stdlib
  std_lib = %w(csv date fileutils json net/http open-uri rss rubygems time uri yaml)
  std_lib << "jekyll"

  importer_docs = site.collections["importers"].docs
  JekyllImport::Importer.subclasses.each do |klass|
    name = klass.name.split("::").last.downcase
    doc  = importer_docs.find { |d| d.basename_without_ext == name }

    cmd = Mercenary::Command.new(name)
    klass.specify_options(cmd)

    deps = klass.require_deps - std_lib
    deps.map! { |dep| dep.start_with?("active_support") ? "activesupport" : dep.split("/")[0] }
    deps = deps - std_lib
    deps.uniq!
    deps.sort!

    doc.data["req_deps"] = deps unless deps.empty?
    unless cmd.options.empty?
      doc.data["cmd_opts"] = (cmd.options.map do |o|
        hsh = { "switch" => o.long }
        if %r!(?<desc>.+?)(?:\z| \(default: (?<default_value>.*)\))! =~ o.description
          hsh["desc"] = desc
          hsh["default_value"] = default_value
          hsh["mandatory"] = true unless default_value
        else
          hsh["desc"] = o.description
        end
        hsh
      end)
    end
  end
end
