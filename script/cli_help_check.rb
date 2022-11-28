require "bundler/setup"
require "jekyll-import"

JekyllImport::Importer.subclasses.each do |importer|
  name = importer.to_s.split("::").last.downcase
  puts "\n\n"
  system "jekyll", "import", name, "--help"
end
