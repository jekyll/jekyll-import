---
layout: docs
title: RSS
prev_section: posterous
link_source:  rss
next_section: s9y
permalink: /docs/rss_podcast/
---

To import your posts from an RSS feed (local or remote), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::RSSPodcast.run({
      "source" => "my_file.xml",
      "body" => ["description"],
      "overwrite" => false
    })'
{% endhighlight %}

The `source` field is required and can be either a local file or a remote one.
The `body` field is optional and is particularly useful to extract the episode description.
The `overwrite` field is optional and is it prevents generating files in the _posts folder if these files already exist.

The importer will prepend to the post the value contained in the <pre><enclosure url=".." /></pre> attribute in order to make the audio file accessible.
