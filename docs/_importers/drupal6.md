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
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Drupal6.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "prefix"   => "mytableprefix",
      "types"    => ["blog", "story", "article"]
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`,
`host` defaults to `"localhost"`, and `prefix` defaults to `""`.

By default, this will pull in nodes of type `blog`, `story`, and `article`.
To specify custom types, you can use the `types` option when you run the
importer:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Drupal6.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "prefix"   => "mytableprefix",
      "types"    => ["blog", "post"]
    })'
{% endhighlight %}

That will import nodes of type `blog` and `post` only.
