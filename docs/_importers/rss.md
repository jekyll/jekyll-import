---
title: RSS
---

To import your posts from an RSS feed (local or remote), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::RSS.run({
      "source" => "my_file.xml"
    })'
{% endhighlight %}

The `source` field is required and can be either a local file or a remote one.
Other optional fields are as follows:
* `canonical_link` – copy original link as `canonical_url` to post. (default: `false`)
* `render_audio` – render `<audio>` element in posts for the enclosure URLs (default: `false`)
* `tag` – add a specific tag to all posts
* `extract_tags` – copies tags from the given subfield on the RSS `<item>`

__Note:__ `tag` and `extract_tags` are exclusive option, both can not be provided together.
