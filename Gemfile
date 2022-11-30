# frozen_string_literal: true

source "https://rubygems.org"
gemspec

gem "jekyll", ENV["JEKYLL_VERSION"] if ENV["JEKYLL_VERSION"]
gem "kramdown-parser-gfm" if ENV["JEKYLL_VERSION"] == "~> 3.9"
gem "test-unit"

group :importers do
  gem "hpricot", "~> 0.8"
  gem "htmlentities", "~> 4.3"
  gem "mysql2", "~> 0.3"
  gem "open_uri_redirections", "~> 0.2"
  gem "pg", "~> 1.0"
  gem "rss", "~> 0.2"
  gem "sequel", "~> 5.62"
  gem "sqlite3", "~> 1.3"
  gem "unidecode", "~> 1.0"
end
