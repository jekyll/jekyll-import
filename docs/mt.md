---
layout: docs
title: Movable Type
prev_section: mephisto
link_source: mt
next_section: posterous
permalink: /docs/mt/
---

To import your posts from [Movable Type](http://movabletype.org), run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::MT.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`
and `host` defaults to `"localhost"`.