---
layout: docs
title: Installation
prev_section: home
next_section: usage
permalink: /docs/installation/
---

Because the importers have many of their own dependencies, they are made
available via a separate gem called
[`jekyll-import`](https://github.com/jekyll/jekyll-import). To use them, all
you need to do is install the gem, and they will become available as part of
Jekyll's standard command line interface.

{% highlight bash %}
$ gem install jekyll-import
{% endhighlight %}

<div class="note warning">
  <h5>Jekyll-import requires you to manually install some dependencies.</h5>
  <p>Most importers require one or more dependencies. In order to keep
  <code>jekyll-import</code>'s footprint small, we don't bundle the gem
  with every plausible dependency. Instead, you will see a nice error
  message describing any missing dependency and how to install it. If
  you're especially savvy, take a look at the <code>require_deps</code>
  method in your chosen importer to install all of the deps in one go.</p>
</div>
