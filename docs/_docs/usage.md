---
layout: docs
title: Usage
prev_section: installation
next_section: behance
permalink: /docs/usage/
---

You should now be all set to run the importers with the following incantation:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::MyImporter.run({
      # options for this importer
    })'
{% endhighlight %}

Where `MyImporter` is the name of the specific importer.

<div class="note info">
  <h5>Note: Always double-check migrated content</h5>
  <p>

    Importers may not distinguish between published or private posts, so
    you should always check that the content Jekyll generates for you appears as
    you intended.

  </p>
</div>
