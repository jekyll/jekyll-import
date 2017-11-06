---
layout: docs
title: WordPress
prev_section: typo
link_source: wordpress
next_section: wordpressdotcom
permalink: /docs/wordpress/
---
<div class="note info">
  <h5>Install additional gems</h5>
  <p>
    To use this importer, you need to install these additional gems:
    `gem install unidecode sequel mysql2 htmlentities`
  </p>
</div>

To import your posts from a self-hosted [WordPress](http://wordpress.org)
installation, run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::WordPress.run({
      "dbname"   => "",
      "user"     => "",
      "password" => "",
      "host"     => "localhost",
      "port"     => "3306",
      "socket"   => "",
      "table_prefix"   => "wp_",
      "site_prefix"    => "",
      "clean_entities" => true,
      "comments"       => true,
      "categories"     => true,
      "tags"           => true,
      "more_excerpt"   => true,
      "more_anchor"    => true,
      "extension"      => "html",
      "status"         => ["publish"]
    })'
{% endhighlight %}

None of the fields are required. Their defaults are as you see above.

<div class="note info">
  <h5>This only imports post &amp; page data &amp; content</h5>
  <p>
    This importer only converts your posts and creates YAML front-matter.
    It does not import any layouts, styling, or external files
    (images, CSS, etc.).
  </p>
</div>
