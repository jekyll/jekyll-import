---
title: Dotclear
prev_section: csv
link_source: dotclear
next_section: drupal6
---

## Notes

* Paths are always resolved relative to current directory.
* Posts will be imported into `_drafts` directory to avoid overwriting any existing file with same filename inside `_posts`.
* Posts will be imported as HTML files with `.html` file extension.
* Excerpts if non-empty will be prepended onto content string separated by a blank line i.e. `<excerpt>\n\n<content>`.
* The same excerpt will be added to front matter to prevent Jekyll from generating a separate excerpt.
* Existing comments linked to posts in the export-file WILL NOT be imported.
* "Categories" are not currently imported from the export-file.
* "Tags" however will be imported and added to relevant posts' front matter.
* Post URLs are imported from the export-file into front matter with key `original_url`.
* Jekyll doesn't manage timezone for individual posts. Therefore, timezone metadata of individual posts will be ignored.
* This importer DOES NOT extract "Blog timezone" from the export-file into Jekyll configuration file.
* Link references to Dotclear's public directory (`/dotclear/public/`) will be altered to (`/assets/dotclear/`).
* All assets will be copied as-is, into the `assets/dotclear` directory.
* Assets will only be imported based on the `media` table in the export-file. Downscaled versions / thumbnails will not be generated.
* Windows-style newline sequences (`"\r\n"`) will be converted into Unix-style line-feed (`"\n"`) sequences.
