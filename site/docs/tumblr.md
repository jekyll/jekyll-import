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
      "user"           => "html", # or "md"
      "password"       => false,  # whether to download images as well.
      "add_highlights" => false,  # whether to wrap code blocks (indented 4 spaces) in a Liquid "highlight" tag
      "rewrite_urls"   => false   # whether to write pages that redirect from the old Tumblr paths to the new Jekyll paths
    })'
{% endhighlight %}

The only required field is `url`. The other fields default to their above
values.