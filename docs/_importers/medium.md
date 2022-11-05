---
layout: docs
title: Medium
prev_section: marley
link_source: medium
next_section: mephisto
permalink: /docs/medium/
---

To import your posts from [Medium](https://medium.com/), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Medium.run({
        "username"       => "name",
        "render_audio"   => "false",
        "canonical_link" => "true",
    })'
{% endhighlight %}

The only required field is `username`. `render_audio` defaults to `false` and `canonical_link` defaults to `true`.
