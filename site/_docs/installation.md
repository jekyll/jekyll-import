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
  <p markdown="1">If you are importing your blog from Drupal 6,7, Joomla,
  Mephisto, Movable Type, Textpattern, or Typo (with mysql db), you need to install
  `mysql` and `sequel` gems. If you are importing from a WordPress database, you
  need to install `mysql2` and `sequel` gems, and if you are importing from Enki
  or Typo (with postgresql db) you need to install `pg` and `sequel` gems.</p>
</div>
