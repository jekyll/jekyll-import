---
title: Movable Type
prev_section: mephisto
link_source: mt
next_section: pebble
---

`comments`, which defaults to false, control the generation of
comment. If `comments` set to true, posts will be generated and placed
in `_comments` directory.

All of the posts and comments will include `post_id` in YAML front
matter to link a post and its comments.

To include imported comments as part of a post, use the yet to merge
[fork of mt-static-comments](https://github.com/shigeya/jekyll-static-comments/tree/mt_static_comments)
to include statically generate comments in your post. Fork and provide
feedback if necessary.
