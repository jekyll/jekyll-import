---
layout: docs
title: RSS
prev_section: posterous
link_source:  rss
next_section: s9y
permalink: /docs/rss/
---

To import your posts from an RSS feed (local or remote), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::RSS.run({
      "source" => "my_file.xml"
    })'
{% endhighlight %}

The `source` field is required and can be either a local file or a remote one.
Other optional fields are as follows
* `canonical_link` add canonical to posts. Default value is `false`
* `render_audio` render <audio> element in posts. Default value is `false`
* `tag` add specific tag to posts
* `extract_tags` extract tags from given key

__Note:__ `tag` and `extract_tags` are exclusive option, both can not be provided together.
