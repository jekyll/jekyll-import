---
layout: docs
title: Blogger
importer: true
prev_section: behance
link_source:  blogger
next_section: csv
permalink: /docs/blogger/
---

To import your posts from your [Blogger](https://www.blogger.com/),
you first have to [export the blog][export-blogger-xml]
to a XML file (`blog-MM-DD-YYYY.xml`),
and run:
{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::Blogger.run({
      "source"                => "/path/to/blog-MM-DD-YYYY.xml",
      "no-blogger-info"       => false, # not to leave blogger-URL info (id and old URL) in the front matter
      "replace-internal-link" => false, # replace internal links using the post_url liquid tag.
    })'
{% endhighlight %}

The only required field is `source`.
The other fields default to their above values.

"Labels" will be included in export as "Tags".

[export-blogger-xml]: https://support.google.com/blogger/answer/97416 "Export or import your blog - Blogger Help"
