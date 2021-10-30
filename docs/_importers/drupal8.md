---
layout: docs
title: Drupal 8
prev_section: drupal7
link_source: drupal8
next_section: easyblog
permalink: /docs/drupal8/
---

To import your posts from a [Drupal 8](http://drupal.org) installation, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Drupal8.run({
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
    JekyllImport::Importers::Drupal8.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "prefix"   => "mytableprefix",
      "types"    => ["blog", "post"]
    })'
{% endhighlight %}

That will import nodes of type `blog` and `post` only.

The default Drupal 8 expects database to be MySQL. If you want to import posts
from Drupal 8 installation with PostgreSQL define `"engine"` as `"postgresql"`:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Drupal8.run({
      "engine"   => "postgresql",
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "prefix"   => "mytableprefix",
      "types"    => ["blog", "story", "article"]
    })'
{% endhighlight %}
