Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'
  s.required_ruby_version = '>= 1.9.2'

  s.name              = 'jekyll-import'
  s.version           = '0.1.0.rc1'
  s.date              = '2013-11-18'
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
    site/.gitignore
    site/CNAME
    site/README
    site/_config.yml
    site/_includes/analytics.html
    site/_includes/docs_contents.html
    site/_includes/docs_contents_mobile.html
    site/_includes/docs_option.html
    site/_includes/docs_ul.html
    site/_includes/footer.html
    site/_includes/header.html
    site/_includes/news_contents.html
    site/_includes/news_contents_mobile.html
    site/_includes/news_item.html
    site/_includes/primary-nav-items.html
    site/_includes/section_nav.html
    site/_includes/top.html
    site/_layouts/default.html
    site/_layouts/docs.html
    site/_layouts/news.html
    site/_layouts/news_item.html
    site/_posts/2013-11-09-jekyll-import-0-1-0-beta4-release.markdown
    site/_posts/2013-11-18-jekyll-import-0-1-0-rc1-released.markdown
    site/css/gridism.css
    site/css/normalize.css
    site/css/pygments.css
    site/css/style.css
    site/docs/contributing.md
    site/docs/csv.md
    site/docs/drupal6.md
    site/docs/drupal7.md
    site/docs/enki.md
    site/docs/google_reader.md
    site/docs/history.md
    site/docs/index.md
    site/docs/installation.md
    site/docs/joomla.md
    site/docs/jrnl.md
    site/docs/marley.md
    site/docs/mephisto.md
    site/docs/mt.md
    site/docs/posterous.md
    site/docs/rss.md
    site/docs/s9y.md
    site/docs/textpattern.md
    site/docs/third-party.md
    site/docs/tumblr.md
    site/docs/typo.md
    site/docs/usage.md
    site/docs/wordpress.md
    site/docs/wordpressdotcom.md
    site/favicon.png
    site/feed.xml
    site/img/article-footer.png
    site/img/footer-arrow.png
    site/img/footer-logo.png
    site/img/logo-2x.png
    site/img/octojekyll.png
    site/img/tube.png
    site/img/tube1x.png
    site/index.html
    site/js/modernizr-2.5.3.min.js
    site/news/index.html
    site/news/releases/index.html
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
