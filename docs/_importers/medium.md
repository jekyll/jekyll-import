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

The `username` refers the medium username and it's a mandatory field.

Other optional fields are as follows:
* `canonical_link` – copy original link as `canonical_url` to post. (default: `true`)
* `render_audio` – render `<audio>` element in posts for the enclosure URLs (default: `false`)
