# frozen_string_literal: true

require_relative "lib/jekyll-import/version"

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.4.0"

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
  s.add_runtime_dependency("jekyll", ">= 3.7", "< 5.0")
  s.add_runtime_dependency("nokogiri", "~> 1.0")
  s.add_runtime_dependency("reverse_markdown", "~> 2.1")

  # development dependencies
  s.add_development_dependency("bundler")
  s.add_development_dependency("rake", "~> 13.0")
  s.add_development_dependency("rdoc", "~> 6.0")

  # test dependencies:
  s.add_development_dependency("redgreen", "~> 1.2")
  s.add_development_dependency("rr", "~> 1.0")
  s.add_development_dependency("rubocop-jekyll", "~> 0.11.0")
  s.add_development_dependency("shoulda", "~> 4.0")
  s.add_development_dependency("simplecov", "~> 0.7")
  s.add_development_dependency("simplecov-gem-adapter", "~> 1.0")

  # site dependencies:
  s.add_development_dependency("launchy", "~> 2.4")
end
