---
layout: docs
title: CSV
prev_section: blogger
link_source: csv
next_section: drupal6
permalink: /docs/csv/
---

To import your posts from a CSV file, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::CSV.run({
      "file" => "my_posts.csv"
    })'
{% endhighlight %}

Your file CSV file will be read in with the following columns:

1. title
2. permalink
3. body
4. published_at
5. filter (e.g. markdown, textile)

If you wish to specify custom front matter for each of your posts, you
can use the `no-front-matter` option to prevent the default front matter
from being written to the imported files:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::CSV.run({
      "file" => "my_posts.csv",
      "no-front-matter" => true
    })'
{% endhighlight %}
