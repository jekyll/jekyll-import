---
layout: docs
title: Tumblr
prev_section: textpattern
link_source: tumblr
next_section: typo
permalink: /docs/tumblr/
---

To import your posts from [Tumblr](http://tumblr.com), run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Tumblr.process({
      "url"            => "http://myblog.tumblr.com",
      "user"           => "html",
      "password"       => false,
      "add_highlights" => false,
      "rewrite_urls"   => false
    })'
{% endhighlight %}

The only required field is `url`. The other fields default to their above
values.