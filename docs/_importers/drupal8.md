---
title: Drupal 8
---

By default, the importer will pull in nodes of type `blog`, `story`, and `article`.
To specify custom types, you may use the `types` option while invoking the importer.

The default Drupal 8 expects database to be MySQL. If you want to import posts from
Drupal 8 installation with PostgreSQL define, pass `postgresql` to the `--engine` option.
