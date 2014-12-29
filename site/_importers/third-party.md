---
layout: docs
title: Third-party
prev_section: wordpressdotcom
next_section: contributing
permalink: /docs/third-party/
---

Various third-party importers for Jekyll have been created separate from this
gem. They are as below:

### Blogger (Blogspot)

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
- [@dseeman](https://github.com/dseeman) created [seriously, yet another](https://gist.github.com/dseeman/a1f0bd96d4511a8f156e)
  importer based on the work of [@ngauthier’s version](https://gist.github.com/1506614).
  it accepts an xml file from any blog (not just blogger) but does not
  include support for comments or drafts. It also converts the html files
  into markdown files.
