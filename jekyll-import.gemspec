# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-import/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '2.2.2'
  s.required_ruby_version = '>= 1.9.3'

  s.name    = 'jekyll-import'
  s.version = JekyllImport::VERSION
  s.license = 'MIT'

  s.summary     = "Import command for Jekyll (static site generator)."
  s.description = "Provides the Import command for Jekyll."

  s.authors  = ["Tom Preston-Werner"]
  s.email    = 'tom@mojombo.com'
  s.homepage = 'http://github.com/jekyll/jekyll-import'

  s.files         = `git ls-files`.split($/).grep(%r{^lib/})
  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.markdown LICENSE]

  # runtime dependencies
  s.add_runtime_dependency('jekyll', ENV['JEKYLL_VERSION'] ? "~> #{ENV['JEKYLL_VERSION']}" : '>= 1.4')
  s.add_runtime_dependency('fastercsv')
  s.add_runtime_dependency('nokogiri')

  # development dependencies
  s.add_development_dependency('rake', "~> 10.1.0")
  s.add_development_dependency('rdoc', "~> 4.0.0")
  s.add_development_dependency('activesupport', '~> 3.2')

  # test dependencies:
  s.add_development_dependency('redgreen', "~> 1.2")
  s.add_development_dependency('shoulda', "~> 3.5")
  s.add_development_dependency('rr', "~> 1.0")
  s.add_development_dependency('simplecov', "~> 0.7")
  s.add_development_dependency('simplecov-gem-adapter', "~> 1.0.1")
  s.add_development_dependency('rubocop') unless RUBY_VERSION < "2.0"

  # migrator dependencies:
  s.add_development_dependency('sequel', "~> 3.42")
  s.add_development_dependency('htmlentities', "~> 4.3")
  s.add_development_dependency('hpricot', "~> 0.8")
  s.add_development_dependency('pg', "~> 0.12")
  s.add_development_dependency('mysql2', "~> 0.3")
  s.add_development_dependency('sqlite3', "~> 1.3.13")
  s.add_development_dependency('behance', "~> 0.3")
  s.add_development_dependency('unidecode')
  s.add_development_dependency('open_uri_redirections')
  s.add_development_dependency('reverse_markdown')

  # site dependencies:
  s.add_development_dependency('launchy', '~> 2.4')
end
