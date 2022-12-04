---
title: S9Y Database
---

This importer only converts your posts and creates YAML front-matter. It does
not import any layouts, styling, or external files (images, CSS, etc).

## Migration Options

- ### `--relative`

  Set this to your URL prefix to convert all the absolute URLs in your posts to
  relative. For example, when set to **`myhost.com/blog`**, URLs like
  `http://myhost.com/blog/lifestyle/7-lucky-post.html` will be converted to
  `/lifestyle/7-lucky-post.html`. Note that you should not include the trailing
  slash `/`, and that `https://` is not supported.

- ### `--linebreak`

  If you used a formatting extension, this option might be useful. Use one of
  the following values to try and replicate your post line breaks as closely as
  possible:

    - #### `wp`

      Replicate the Wordpress line break behavior, the default for S9Y.

    - #### `nokogiri`

      Uses the `nokogiri` gem to interpret entries as XHTML formatted. If you
      write HTML entries, this preserves the HTML line breaks.

    - #### `ignore`

      This option does not process the entries at all, but imports them into
      Jekyll verbatim. This may be useful if you wrote your entries in a
      Jekyll-compatible format.

## Extension Options

This importer supports some of the most common S9Y plugins.

- ### `--includeentry`

  Use this option to transclude entries like the `includeentry`plugin.
  The current static content of the entry will be included. Future updates will
  not be synced.

- ### `--excerpt_separator`

  S9Y treats the regular post body as an excerpt, displaying the extended body
  only in the post details. Jekyll only shows the first paragraph of the post
  as an excerpt. This option allows you to restore the S9Y behavior: posts with
  extended body will have the specified separator added to their front matter,
  and you can modify your index layout to show the excerpts.

- ### `--imgfig`

  By default, this converts references to S9Y's media library into HTML`figure`
  tags. Set it to `false` to keep the original references, which you'll have to
  update manually.
