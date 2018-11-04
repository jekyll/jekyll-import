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
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Tumblr.run({
      "url"            => "http://myblog.tumblr.com",
      "format"         => "html", # or "md"
      "grab_images"    => false,  # whether to download images as well.
      "add_highlights" => false,  # whether to wrap code blocks (indented 4 spaces) in a Liquid "highlight" tag
      "rewrite_urls"   => false   # whether to write pages that redirect from the old Tumblr paths to the new Jekyll paths
    })'
{% endhighlight %}

or from the commande line, .e.g.:

{% highlight bash %}
jekyll import tumblr --url=http://myblog.tumblr.com --format=md --grab_images --rewrite_urls
{% endhighlight %}


The only required field is `url`. The other fields default to their above
values.
