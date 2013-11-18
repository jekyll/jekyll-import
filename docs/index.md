---
layout: docs
title: Blog migrations
next_section: usage
permalink: /docs/home/
---

If you’re switching to Jekyll from another blogging system, Jekyll’s importers
can help you with the move. Most methods listed on this page require read access
to the database from your old system to generate posts for Jekyll. Each method
generates `.markdown` posts in the `_posts` directory based on the entries in
the foreign system.

## Preparing for migrations

Because the importers have many of their own dependencies, they are made
available via a separate gem called
[`jekyll-import`](https://github.com/jekyll/jekyll-import). To use them, all
you need to do is install the gem, and they will become available as part of
Jekyll's standard command line interface.

{% highlight bash %}
$ gem install jekyll-import --pre
{% endhighlight %}

<div class="note warning">
  <h5>Jekyll-import requires you to manually install some dependencies.</h5>
  <p markdown="1">If you are importing your blog from Drupal 6,7, Joomla,
  Mephisto, Movable Type, Textpattern, or Typo (with mysql db), you need to install
  `mysql` and `sequel` gems. If you are importing from a WordPress database, you
  need to install `mysql2` and `sequel` gems, and if you are importing from Enki
  or Typo (with postgresql db) you need to install `pg` and `sequel` gems.</p>
</div>

You should now be all set to run the importers below. If you ever get stuck, you
can see help for each importer:

{% highlight bash %}
$ jekyll help import           # => See list of importers
$ jekyll help import IMPORTER  # => See importer specific help
{% endhighlight %}

Where IMPORTER is the name of the specific importer.

<div class="note info">
  <h5>Note: Always double-check migrated content</h5>
  <p>

    Importers may not distinguish between published or private posts, so
    you should always check that the content Jekyll generates for you appears as
    you intended.

  </p>
</div>

## Blogger (Blogspot)

To import posts from Blogger, see [this post about migrating from Blogger to
Jekyll](http://blog.coolaj86.com/articles/migrate-from-blogger-to-jekyll.html). If
that doesn’t work for you, you might want to try some of the following
alternatives:

- [@kennym](https://github.com/kennym) created a [little migration
  script](https://gist.github.com/1115810), because the solutions in the
  previous article didn't work out for him.
- [@ngauthier](https://github.com/ngauthier) created [another
  importer](https://gist.github.com/1506614) that imports comments, and does so
  via blogger’s archive instead of the RSS feed.
- [@juniorz](https://github.com/juniorz) created [yet another
  importer](https://gist.github.com/1564581) that works for
  [Octopress](http://octopress.org). It is like [@ngauthier’s
  version](https://gist.github.com/1506614) but separates drafts from posts, as
  well as importing tags and permalinks.

## Other Systems

If you have a system for which there is currently no migrator, consider writing
one and sending us [a pull request](https://github.com/jekyll/jekyll-import).
