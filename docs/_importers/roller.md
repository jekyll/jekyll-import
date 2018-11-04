---
layout: docs
title: Roller
prev_section: wordpressdotcom
link_source: roller
next_section: third-party
permalink: /docs/roller/
---
<div class="note info">
  <h5>Install additional gems</h5>
  <p>
    To use this importer, you need to install these additional gems:
    `gem install unidecode sequel mysql2 htmlentities`
  </p>
</div>

To import your posts from a self-hosted [RollerBlog](https://roller.apache.org/)
installation, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Roller.run({
      "dbname"         => "",
      "user"           => "",
      "password"       => "",
      "host"           => "localhost",
      "port"           => "3306",
      "socket"         => "",
      "clean_entities" => true,
      "comments"       => true,
      "categories"     => true,
      "tags"           => true,
      "more_excerpt"   => true,
      "more_anchor"    => true,
      "extension"      => "html",
      "status"         => ["PUBLISHED"]
    })'
{% endhighlight %}

Only the variables "dbname", "user" and "password" are required, the rest are optional and default to what is shown above. Currently this importer assumes a MySQL database.

<div class="note info">
  <h5>This only imports post content</h5>
  <p>
    This importer only converts your posts and creates YAML front-matter.
    It does not import any layouts, styling, or external files
    (images, CSS, etc.).
  </p>
</div>
