Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'
  s.required_ruby_version = '>= 1.9.2'

  s.name              = 'jekyll-import'
  s.version           = '0.1.0.beta4'
  s.date              = '2013-11-09'
  s.rubyforge_project = 'jekyll-import'

  s.summary     = "Import command for Jekyll (static site generator)."
  s.description = "Provides the Import command for Jekyll."

  s.authors  = ["Tom Preston-Werner"]
  s.email    = 'tom@mojombo.com'
  s.homepage = 'http://github.com/jekyll/jekyll-import'
  s.license  = 'MIT'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.markdown LICENSE]

  s.add_runtime_dependency('jekyll', '~> 1.3')
  s.add_runtime_dependency('fastercsv')
  s.add_runtime_dependency('nokogiri')
  s.add_runtime_dependency('safe_yaml', '~> 0.9.7')

  # development dependencies
  s.add_development_dependency('rake', "~> 10.1.0")
  s.add_development_dependency('rdoc', "~> 4.0.0")
  s.add_development_dependency('activesupport', '~> 3.2')

  # test dependencies:
  s.add_development_dependency('redgreen', "~> 1.2")
  s.add_development_dependency('shoulda', "~> 3.3.2")
  s.add_development_dependency('rr', "~> 1.0")
  s.add_development_dependency('simplecov', "~> 0.7")
  s.add_development_dependency('simplecov-gem-adapter', "~> 1.0.1")

  # migrator dependencies:
  s.add_development_dependency('sequel', "~> 3.42")
  s.add_development_dependency('htmlentities', "~> 4.3")
  s.add_development_dependency('hpricot', "~> 0.8")
  s.add_development_dependency('mysql', "~> 2.8")
  s.add_development_dependency('pg', "~> 0.12")
  s.add_development_dependency('mysql2', "~> 0.3")

  # = MANIFEST =
  s.files = %w[
    Gemfile
    History.markdown
    LICENSE
    README.markdown
    Rakefile
    jekyll-import.gemspec
    lib/jekyll-import.rb
    lib/jekyll-import/importer.rb
    lib/jekyll-import/importers.rb
    lib/jekyll-import/importers/csv.rb
    lib/jekyll-import/importers/drupal6.rb
    lib/jekyll-import/importers/drupal7.rb
    lib/jekyll-import/importers/enki.rb
    lib/jekyll-import/importers/google_reader.rb
    lib/jekyll-import/importers/joomla.rb
    lib/jekyll-import/importers/jrnl.rb
    lib/jekyll-import/importers/marley.rb
    lib/jekyll-import/importers/mephisto.rb
    lib/jekyll-import/importers/mt.rb
    lib/jekyll-import/importers/posterous.rb
    lib/jekyll-import/importers/rss.rb
    lib/jekyll-import/importers/s9y.rb
    lib/jekyll-import/importers/textpattern.rb
    lib/jekyll-import/importers/tumblr.rb
    lib/jekyll-import/importers/typo.rb
    lib/jekyll-import/importers/wordpress.rb
    lib/jekyll-import/importers/wordpressdotcom.rb
    lib/jekyll/commands/import.rb
    test/helper.rb
    test/test_jrnl_importer.rb
    test/test_mt_importer.rb
    test/test_tumblr_importer.rb
    test/test_wordpress_importer.rb
    test/test_wordpressdotcom_importer.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
