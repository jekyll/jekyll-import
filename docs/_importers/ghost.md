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
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Ghost.run({
      "dbfile"   => "/path/to/your/ghost.db"
    })'
{% endhighlight %}

There are no required fields. `dbfile` defaults to `"ghost.db"`.

If you have a Ghost backup file, consider using another tool called [jekyll_ghost_importer](https://github.com/eloyesp/jekyll_ghost_importer) to import your content. It is a separate gem and docs can be found at the link provided.
