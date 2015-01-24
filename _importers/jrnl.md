---
layout: docs
title: Jrnl
prev_section: joomla3
link_source: jrnl
next_section: marley
permalink: /docs/jrnl/
---

To import your posts from [Jrnl](http://maebert.github.io/jrnl/), run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Jrnl.run({
      "file"        => "~/journal.txt",
      "time_format" => "%Y-%m-%d %H:%M",
      "extension"   => "md",
      "layout"      => "post"
    })'
{% endhighlight %}

None of the fields are mandatory. The default to the values in the example
block above.
