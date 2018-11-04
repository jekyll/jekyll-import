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
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Posterous.run({
      "email"     => "myemail",
      "password"  => "mypassword",
      "api_token" => "mytoken"
    })'
{% endhighlight %}

All three fields are required.

There is also an [alternative Posterous
migrator](https://github.com/pepijndevos/jekyll/blob/patch-1/lib/jekyll/migrators/posterous.rb)
that maintains permalinks and attempts to import images too.
