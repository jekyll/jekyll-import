---
layout: docs
title: Marley
prev_section: jrnl
link_source: marley
next_section: mephisto
permalink: /docs/marley/
---

To import your posts from [Marley](https://github.com/karmi/marley), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Marley.run({
      "marley_data_dir" => "my_marley_data_dir"
    })'
{% endhighlight %}

The `marley_data_dir` field is required and points to the directory in which
your Marley data resides.
