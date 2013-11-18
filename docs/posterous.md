---
layout: docs
title: Posterous
prev_section: mt
link_source: posterous
next_section: rss
permalink: /docs/posterous/
---

To import your posts from [Posterous](http://movabletype.org), run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::MT.process({
      "email"     => "myemail",
      "password"  => "mypassword",
      "api_token" => "mytoken"
    })'
{% endhighlight %}

All three fields are required.
