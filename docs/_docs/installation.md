---
doc_order: 2
---

Because the importers have many of their own dependencies, they are made
available to Jekyll via a separate gem named `jekyll-import`. To use them, all
you need to do is install the gem, and they will become available as part of
Jekyll's standard command line interface.

```bash
gem install jekyll-import
```
<div class="note warning" markdown="1">
  Jekyll Import requires you to manually install some dependencies.

  Most importers require one or more dependencies. In order to keep the plugin's
  footprint small, we don't bundle the gem with every plausible dependency.
  Instead, you will see a nice error message describing any missing dependency
  and how to install it. We also document such dependencies in the dedicated
  page for a given importer.
</div>
