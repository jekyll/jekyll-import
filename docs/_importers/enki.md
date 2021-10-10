---
layout: docs
title: Enki
prev_section: easyblog
link_source:  enki
next_section: ghost
permalink: /docs/enki/
---

To import your posts from a [Enki](https://github.com/xaviershay/enki) installation, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Enki.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`
and `host` defaults to `"localhost"`.
