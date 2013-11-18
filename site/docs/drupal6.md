---
layout: docs
title: Drupal 6
prev_section: csv
link_source: drupal6
next_section: drupal7
permalink: /docs/drupal6/
---

To import your posts from a [Drupal 6](http://drupal.org) installation, run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Drupal6.process({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "prefix"   => "mytableprefix"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`,
`host` defaults to `"localhost"`, and `prefix` defaults to `""`.
