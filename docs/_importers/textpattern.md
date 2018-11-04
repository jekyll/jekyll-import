---
layout: docs
title: Textpattern
prev_section: s9y
link_source: textpattern
next_section: tumblr
permalink: /docs/textpattern/
---

To import your posts from [Textpattern](http://textpattern.com), run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::TextPattern.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost"
    })'
{% endhighlight %}

The only required fields are `dbname` and `user`. `password` defaults to `""`
and `host` defaults to `"localhost"`.

You will need to run the above from the parent directory of your `_import`
folder. For example, if `_import` is located in `/path/source/_import`, you will
need to run this code from `/path/source`. The hostname defaults to `localhost`,
all other variables are required. You may need to adjust the code used to filter
entries. Left alone, it will attempt to pull all entries that are live or
sticky.
