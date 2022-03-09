---
layout: docs
title: S9Y Database
prev_section: s9y
link_source:  s9ydatabase
next_section: textpattern
permalink: /docs/s9ydatabase/
---

To import your posts from a self-hosted [S9Y](http://www.s9y.org) database, run:

{% highlight bash %}
$ ruby -r rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::S9YDatabase.run({
      "dbname"         => "s9y_blog",
      "user"           => "root",
      "password"       => "",
      "host"           => "localhost",
      "table_prefix"   => "serendipity_",
      "clean_entities" => false,
      "comments"       => true,
      "categories"     => true,
      "tags"           => true,
      "extension"      => "html",
      "drafts "        => true,
      "markdown"       => false,
      "permalinks"     => false
    })
{% endhighlight %}

<div class="note info">
  <h5>This only imports post &amp; page data &amp; content</h5>
  <p>
    This importer only converts your posts and creates YAML front-matter.
    It does not import any layouts, styling, or external files
    (images, CSS, etc.).
  </p>
</div>

<div>
  <h5>Migration Options</h5>
  <p>
    This importer now supports two options to help migrate your blog to a new
    hosting provider.
  </p>
  <ul>
    <li>
      <strong>relative</strong>
      <p>
        Set this to your URL prefix to convert all the absolute URLs in your
        posts to relative. For example, when set to
        <code>myhost.com/blog</code>, URLs like
        <code>http://myhost.com/blog/lifestyle/7-lucky-post.html</code> will be
        converted to <code>/lifestyle/7-lucky-post.html</code>. Note that you
        should not include the trailing <code>/</code> slash, and that https:
        is not yet supported.
      </p>
    </li><li>
      <strong>linebreak</strong>
      <p>
        If you used a formatting extension, this option might be useful. Use
        one of the following values to try and replicate your post line breaks as
        closely as possible:
      </p>
        <ul>
            <li><strong>wp</strong> (the default)
                <p>Replicate the Wordpress line break behavior, the default for S9Y.</p>
            </li>
            <li><strong>nokogiri</strong>
                <p>
                  Uses the <code>nokogiri</code> gem to interpret entries as XHTML
                  formatted.  If you write HTML entries, this preserves the HTML
                  line breaks.
                </p>
            </li>
            <li><strong>ignore</strong>
                <p>
                  This option does not process the entries at all, but imports them
                  into Jekyll verbatim. This may be useful if you wrote your entries in
                  a Jekyll-compatible format.
                </p>
            </li>
        </ul>
    </li>
  </ul>

  <h5>Extension Options</h5>
  <p>
    This importer now supports some of the most common S9Y plugins.
  </p>
  <ul>
    <li>
      <strong>includeentry</strong>
      <p>
        Set this true to transclude entries like the <code>includeentry</code>
        plugin. The current, static content of the entry will be included.
        Future updates will not be synced.
      </p>
    </li><li>
      <strong>excerpt_separator</strong>
      <p>
        S9Y treats the regular post body as an excerpt, displaying the extended
        body only in the post details. Jekyll only shows the first paragraph of
        the post as an excerpt. This option allows you to restore the S9Y
        behavior: posts with extended body will have the specified separator
        added to their front matter, and you can modify your index layout to
        show the excerpts.
      </p>
    </li><li>
      <strong>imgfig</strong>
      <p>
        By default, this converts references to S9Y's media library into HTML
        <code>figure</code> tags. Set it to <code>false</code> to keep the
        original references, which you'll have to update manually.
      </p>
    </li>
  </ul>
</div>
