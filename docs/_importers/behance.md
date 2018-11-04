---
layout: docs
title: Behance
importer: true
prev_section: usage
link_source:  behance
next_section: blogger
permalink: /docs/behance/
---

To import your posts from your [Behance](http://behance.com), generate an API token for your user account and run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Behance.run({
      "user"      => "my_username",
      "api_token" => "my_api_token"
    })'
{% endhighlight %}

Both `user` and `api_token` are required.
