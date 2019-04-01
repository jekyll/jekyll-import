---
layout: docs
title: Dotclear
prev_section: csv
link_source: dotclear
next_section: drupal6
permalink: /docs/dotclear/
---

To import your posts from a dotclear file, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Dotclear.run({
      "datafile" => "2019-....-backup.txt",
      "mediafolder" => "path/to/the/media (media.zip inflated)"
    })'
{% endhighlight %}
