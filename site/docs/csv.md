---
layout: docs
title: CSV
prev_section: quickstart
link_source: csv
next_section: drupal6
permalink: /docs/csv/
---

To import your posts from a CSV file, run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
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
