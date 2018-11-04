---
layout: docs
title: S9Y
prev_section: rss
link_source:  s9y
next_section: s9ydatabase
permalink: /docs/s9y/
---

To import your posts from an [S9Y](http://www.s9y.org) feed, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::S9Y.run({
      "source" => "http://blog.example.com/rss.php?version=2.0&all=1"
    })'
{% endhighlight %}

The `source` field is required.
