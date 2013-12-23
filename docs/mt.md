---
layout: docs
title: Movable Type
prev_section: mephisto
link_source: mt
next_section: posterous
permalink: /docs/mt/
---

To import your posts from [Movable Type](http://movabletype.org), run:

{% highlight bash %}
$ ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::MT.run({
      "dbname"   => "name",
      "user"     => "myuser",
      "password" => "mypassword",
      "host"     => "myhost",
      "comments"     => true
    })'
{% endhighlight %}

Posts will be generated and placed in `_posts` directory.

The only required fields are `dbname` and `user`. `password` defaults to `""`
and `host` defaults to `"localhost"`.

`comments`, which defaults to false, control the generation of
comment. If `comments` set to true, posts will be generated and placed
in `_comments` directory.


All of the posts and comments will include `post_id` in YAML front
matter to link a post and its comments.

To include imported comments as part of a post, use the yet to merge
[fork of mt-static-comments](https://github.com/shigeya/jekyll-static-comments/tree/mt_static_comments)
to include statically generate comments in your post. Fork and provide
feedback if necessary.
