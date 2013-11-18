---
layout: docs
title: Drupal 7
prev_section: drupal6
next_section: enki
permalink: /docs/drupal7/
---

To import your posts from a [Drupal 7](http://drupal.org) installation, run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Drupal7.process({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "prefix"   => "mytableprefix"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`,
`host` defaults to `"localhost"`, and `prefix` defaults to `""`.
