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
        "render_audio"   => false,
        "canonical_link" => false,
    })'
{% endhighlight %}

The `username` refers to the medium username, and it's a mandatory field.

Other optional fields are as follows:
* `canonical_link` – copy original link as `canonical_url` to post. (default: `false`)
* `render_audio` – render `<audio>` element in posts for the enclosure URLs. (default: `false`)

_Note:_ This importer will also import the existing tags/labels from Medium post and include the tags to [Front Matter](https://jekyllrb.com/docs/front-matter/).
