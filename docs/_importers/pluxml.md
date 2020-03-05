---
layout: docs
title: PluXML
prev_section: mt
link_source:  pluxml
next_section: posterous
permalink: /docs/pluxml/
---

To import your posts and drafts from a PluXML blog, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Pluxml.run({
      "source" => "/pluxml/data/articles"
      "layout" => "your_layout"
    })'
{% endhighlight %}

The `source` field is required.

The `layout` field is optional, it will set the layout in each post and draft imported.
