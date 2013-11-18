---
layout: docs
title: WordPress.com
prev_section: wordpress
link_source: wordpressdotcom
permalink: /docs/wordpressdotcom/
---

To import your posts from a [WordPress.com](http://wordpress.com) blog, run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::WordpressDotCom.process({
      "source" => "wordpress.xml"
    })'
{% endhighlight %}

The `source` field is not required. Its default is what you see above.
