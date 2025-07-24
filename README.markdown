# jekyll-import

[![Gem Version](https://img.shields.io/gem/v/jekyll-import.svg)](https://rubygems.org/gems/jekyll-import)
[![Continuous Integration](https://github.com/jekyll/jekyll-import/actions/workflows/ci.yml/badge.svg)](https://github.com/jekyll/jekyll-import/actions/workflows/ci.yml)

The new __Jekyll__ command for importing from various blogs to Jekyll format.

**Note: _migrators_ are now called _importers_ and are only available if one installs the `jekyll-import` _gem_.**

## How `jekyll-import` works:

### Jekyll v2.x and higher

1. Install the _rubygem_ with `gem install jekyll-import`.
2. Run `jekyll-import IMPORTER [options]`

### Jekyll v1.x

Launch IRB:

```ruby
# 1. Require jekyll-import
irb> require 'jekyll-import'
# 2. Choose the importer you'd like to use.
irb> importer_class = "Behance" # an example, there are many others!
# 3. Run it!
irb> JekyllImport::Importers.const_get(importer_class).run(options_hash)
```

## Documentation

jekyll-import has its own documentation site, found at https://import.jekyllrb.com.
Dedicated [documentation for each migrator](https://import.jekyllrb.com/docs/home/) is available there.

## Contributing

1. Make your changes to the appropriate importer file(s) in `lib/jekyll-import`
1. For local testing only, bump the version in lib/jekyll-import/version.rb according to [semantic versioning](https://semver.org/) rules.  Let's call this new version x.y.z as a placeholder.
1. Run `gem build jekyll-import.gemspec` to build the gem
1. Run `gem install ./jekyll-import-x.y.z.gem` to install the gem globally on your machine
1. In the project that depends on jekyll-import, bump the version to x.y.z in your Gemfile.lock
1. In that same project, run `bundle install` to validate that updated dependency version
1. Again in that project, run `bundle info jekyll-import` to ensure that it is referencing the new version
1. Run jekyll-import as usual