---
layout: docs
title: Typo
prev_section: tumblr
link_source: typo
next_section: wordpress
permalink: /docs/typo/
---

To import your posts from Typo (now [Publify](http://publify.co)), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Typo.run({
      "server"   => "mysql",
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost"
    })'
{% endhighlight %}

The only required fields are `server`, `dbname`, and `user`. `password`
defaults to `""` and `host` defaults to `"localhost"`.

This code has only been tested with Typo version 4+.
