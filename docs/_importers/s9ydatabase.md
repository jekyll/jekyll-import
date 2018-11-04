---
layout: docs
title: S9Y Database
prev_section: s9y
link_source:  s9ydatabase
next_section: textpattern
permalink: /docs/s9ydatabase/
---

<div class="note info">
  <h5>Install additional gems</h5>
  <p>
    To use this importer, you need to install these additional gems:
    `gem install unidecode sequel mysql2 htmlentities reverse_markdown`
  </p>
</div>


To import your posts from a self-hosted [S9Y](http://www.s9y.org) database, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::S9YDatabase.run({
      "dbname"         => "s9y_blog",
      "user"           => "root",
      "password"       => "",
      "host"           => "localhost",
      "table_prefix"   => "serendipity_",
      "clean_entities" => false,
      "comments"       => true,
      "categories"     => true,
      "tags"           => true,
      "extension"      => "html",
      "drafts "        => true,
      "markdown"       => false,
      "permalinks"     => false
    })
{% endhighlight %}

<div class="note info">
  <h5>This only imports post &amp; page data &amp; content</h5>
  <p>
    This importer only converts your posts and creates YAML front-matter.
    It does not import any layouts, styling, or external files
    (images, CSS, etc.).
  </p>
</div>
