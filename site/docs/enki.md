---
layout: docs
title: Enki
prev_section: drupal7
link_source:  enki
next_section: google_reader
permalink: /docs/enki/
---

To import your posts from a [Enki](http://enkiblog.com) installation, run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Enki.process({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`
and `host` defaults to `"localhost"`.
