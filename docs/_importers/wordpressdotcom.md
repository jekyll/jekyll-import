---
title: WordPress.com
prev_section: wordpress
link_source:  wordpressdotcom
next_section: third-party
---

The `source`, `no_fetch_images`, and `assets_folder` fields are not required.
Their default values are what you see above.

<div class="note">
  <h5>ProTip™: WordPress.com Export Tool</h5>
  <p markdown="1">If you are migrating from a WordPress.com account, you can
  access the export tool at the following URL:
  `https://YOUR-USER-NAME.wordpress.com/wp-admin/export.php`.</p>
</div>

### Further WordPress migration alternatives

While the above method works, it doesn't import absolutely every piece of
metadata. If you need to import custom fields from your pages and posts,
the following resources might be useful to you:

- [Exitwp](https://github.com/thomasf/exitwp) is a configurable tool written in
  Python for migrating one or more WordPress blogs into Jekyll (Markdown) format
  while keeping as much metadata as possible. Exitwp also downloads attachments
  and pages.
- [A great
  article](https://vitobotta.com/2011/03/28/migrate-from-wordpress-to-jekyll/) with a
  step-by-step guide for migrating a WordPress blog to Jekyll while keeping most
  of the structure and metadata.
- [wpXml2Jekyll](https://github.com/theaob/wpXml2Jekyll) is an executable
  windows application for creating Markdown posts from your WordPress XML file.
