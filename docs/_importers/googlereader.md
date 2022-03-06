---
layout: docs
title: Google Reader
prev_section: enki
link_source:  google_reader
next_section: joomla
permalink: /docs/google_reader/
---

To import your posts from a [Google Reader](http://reader.google.com) XML dump file, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::GoogleReader.run({
      "source" => "my_file.xml"
    })'
{% endhighlight %}

The `source` field is required.
