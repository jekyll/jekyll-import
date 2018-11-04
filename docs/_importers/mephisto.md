---
layout: docs
title: Mephisto
prev_section: marley
link_source: mephisto
next_section: mt
permalink: /docs/mephisto/
---

To import your posts from [Mephisto](http://www.mephistoblog.com), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Mephisto.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`
and `host` defaults to `"localhost"`.