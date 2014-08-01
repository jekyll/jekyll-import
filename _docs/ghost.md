---
layout: docs
title: Ghost
prev_section: enki
link_source:  ghost
next_section: google_reader
permalink: /docs/ghost/
---

To import your posts from your self-hosted Ghost instance, you first have to download your ghost.db from your server and run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Ghost.run({
      "dbfile"   => "/path/to/your/ghost.db"
    })'
{% endhighlight %}

There are no required fields. `dbfile` defaults to `"ghost.db"`.
