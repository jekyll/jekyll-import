---
layout: docs
title: EasyBlog
prev_section: drupal7
link_source:  easyblog
next_section: enki
permalink: /docs/easyblog/
---

To import your posts from a [EasyBlog](http://stackideas.com/easyblog) installation, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Easyblog.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "prefix"   => "mytableprefix"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`,
`host` defaults to `"localhost"`
`prefix` defaults to `"jos_"`. This will export all articles (in any state). Category and tags will be included in export.
