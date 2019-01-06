# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-import/version"

Gem::Specification.new do |s|
  s.rubygems_version = ">= 2.5"
  s.required_ruby_version = ">= 2.3"

  s.name    = "jekyll-import"
  s.version = JekyllImport::VERSION
  s.license = "MIT"

  s.summary     = "Import command for Jekyll (static site generator)."
  s.description = "Provides the Import command for Jekyll."

  s.authors  = ["Tom Preston-Werner", "Parker Moore", "Matt Rogers"]
  s.email    = "maintainers@jekyllrb.com"
  s.homepage = "http://github.com/jekyll/jekyll-import"

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR).grep(%r!^lib/!)
  s.require_paths = %w(lib)

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w(README.markdown LICENSE)

  # runtime dependencies
  s.add_runtime_dependency("fastercsv", "~> 1.0")
  s.add_runtime_dependency("jekyll", ENV["JEKYLL_VERSION"] ? "~> #{ENV["JEKYLL_VERSION"]}" : "~> 3.0")
  s.add_runtime_dependency("nokogiri", "~> 1.0")
  s.add_runtime_dependency("reverse_markdown", "~> 1.0")

  # development dependencies
  s.add_development_dependency("activesupport", "~> 4.2")
  s.add_development_dependency("bundler")
  s.add_development_dependency("rake", "~> 12.0")
  s.add_development_dependency("rdoc", "~> 6.0")

  # test dependencies:
  s.add_development_dependency("redgreen", "~> 1.2")
  s.add_development_dependency("rr", "~> 1.0")
  s.add_development_dependency("rubocop-jekyll", "~> 0.4")
  s.add_development_dependency("shoulda", "~> 3.5")
  s.add_development_dependency("simplecov", "~> 0.7")
  s.add_development_dependency("simplecov-gem-adapter", "~> 1.0")

  # migrator dependencies:
  s.add_development_dependency("behance", "~> 0.3")
  s.add_development_dependency("hpricot", "~> 0.8")
  s.add_development_dependency("htmlentities", "~> 4.3")
  s.add_development_dependency("mysql2", "~> 0.3")
  s.add_development_dependency("open_uri_redirections", "~> 0.2")
  s.add_development_dependency("pg", "~> 0.12")
  s.add_development_dependency("sequel", "~> 3.42")
  s.add_development_dependency("sqlite3", "~> 1.3")
  s.add_development_dependency("unidecode", "~> 1.0")

  # site dependencies:
  s.add_development_dependency("launchy", "~> 2.4")
end
