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

  all_files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.files         = all_files.grep(%r!^(exe|lib|rubocop)/|^.rubocop.yml$!)
  s.executables   = all_files.grep(%r!^exe/!) { |f| File.basename(f) }
  s.bindir        = "exe"
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

  # Dependencies not needed during building / deployment of the documentation site.
  #
  # Containing them within a conditional block in the gemspec instead of using a Bundler
  # group in the Gemfile ensures that they remain listed in the page at Rubygems.org.

  unless ENV["DOCS_DEPLOY"]
    # test dependencies:
    s.add_development_dependency("redgreen", "~> 1.2")
    s.add_development_dependency("rr", "~> 3.1")
    s.add_development_dependency("rubocop-jekyll", "~> 0.11.0")
    s.add_development_dependency("shoulda", "~> 4.0")
    s.add_development_dependency("simplecov", "~> 0.7")
    s.add_development_dependency("simplecov-gem-adapter", "~> 1.0")

    # importer dependencies:
    # s.add_development_dependency("behance", "~> 0.3") # uses outdated dependencies
    s.add_development_dependency("hpricot", "~> 0.8")
    s.add_development_dependency("htmlentities", "~> 4.3")
    s.add_development_dependency("mysql2", "~> 0.3")
    s.add_development_dependency("open_uri_redirections", "~> 0.2")
    s.add_development_dependency("pg", "~> 1.0")
    s.add_development_dependency("rss", "~> 0.2")
    s.add_development_dependency("sequel", "~> 5.62")
    s.add_development_dependency("sqlite3", "~> 1.3")
    s.add_development_dependency("unidecode", "~> 1.0")
  end

  # site dependencies:
  s.add_development_dependency("launchy", "~> 3.0")
end
