---
layout: docs
title: RSS
prev_section: posterous
link_source:  rss
next_section: s9y
permalink: /docs/rss/
---

To import your posts from an RSS feed (local or remote), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::RSS.run({
      "source" => "my_file.xml"
    })'
{% endhighlight %}

The `source` field is required and can be either a local file or a remote one.
