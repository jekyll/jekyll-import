module JekyllImport
  module Importers
    Dir.chdir(File.expand_path(File.join("importers"), File.dirname(__FILE__))) do
      Dir.entries(".").each do |f|
        next if f[0..0].eql?(".")
        require "jekyll-import/importers/#{f}"
      end
    end
  end
end
