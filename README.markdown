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
