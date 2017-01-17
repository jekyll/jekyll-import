---
layout: docs
title: Joomla
prev_section: google_reader
link_source:  joomla
next_section: joomla3
permalink: /docs/joomla/
---

To import your posts from a [Joomla](http://joomla.org) installation, run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Joomla.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "section"  => "thesection",
      "prefix"   => "mytableprefix"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`,
`host` defaults to `"localhost"`, and `section` defaults to `"1"` and `prefix`
defaults to `"jos_"`.
