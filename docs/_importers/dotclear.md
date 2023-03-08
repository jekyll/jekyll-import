---
title: Dotclear
prev_section: csv
link_source: dotclear
next_section: drupal6
---

## Notes

* This importer only imports posts and media files (referred to as "assets" henceforth) in the given `mediafolder` directory.
* Paths are always resolved relative to current directory.
* Posts will be imported into `_drafts` directory to avoid overwriting any existing file with same filename inside `_posts`.
* Posts will be imported as HTML files with `.html` file extension.
* Existing comments linked to posts in the export-file WILL NOT be imported.
* "Categories" are not currently imported from the export-file.
* "Tags" however will be imported and added to relevant posts' front matter.
* Post URLs are imported from the export-file into front matter with key `dotclear_post_url`.
* Jekyll doesn't manage timezone for individual posts. Therefore, timezone metadata of individual posts will be ignored.
* This importer DOES NOT extract "Blog timezone" from the export-file into Jekyll configuration file.
* Link references to Dotclear's public directory (`/dotclear/public/`) will be altered to (`/assets/dotclear/`).
* All assets will be copied as-is, into the `assets/dotclear` directory.
* Windows-style newline sequences (`"\r\n"`) will be converted into Unix-style line-feed (`"\n"`) sequences.
