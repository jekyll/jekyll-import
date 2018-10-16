---
layout: docs
title: Contributing
prev_section: third-party
next_section: history
permalink: /docs/contributing/
---

jekyll-import is entirely open-source, which means we need your help to make it better!

## Ran into an Issue?

Found an issue with one of the importers? Sorry about that! In order to better assist you and make sure the problem never happens, again, we would love for you to do a few things:

1. Collection information about your system: operating system and version, Ruby version, Jekyll version, jekyll-import version.
2. Which importer are you using? Note this.
3. Collect the relevant data. This may be data from your database or input file. This will help us diagnose where the issue occurred.
4. Ensure the `--trace` option is specified if you're running `jekyll import` from the command-line.
4. [Open a new issue]({{ site.repository }}/issues/new) describing the four above points, as well as what you expected the outcome of your incantation to be.

You should receive help soon. As always, check out [our help repo](https://talk.jekyllrb.com/) if you just have a question.


## Creating a New Importer

So you have a new system you want to be able to import from? Great! It's pretty simple to add a new importer to `jekyll-import`. In this example, we'll be creating the `Columbus` importer.

First thing's first: create the file where the importer will go. In this case, that will be `lib/jekyll-import/importers/columbus.rb`.
Inside this file, we'll add this template:

{% highlight ruby %}
module JekyllImport
  module Importers
    class Columbus < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w(
          safe_yaml
          mysql2
        ))
      end

      def self.specify_options(c)
        c.option "dbname",   "--dbname DB",   "Database name (default: '')"
        c.option "user",     "--user USER",   "Database user name (default: '')"
        c.option "password", "--password PW", "Database user's password (default: '')"
        c.option "host",     "--host HOST",   "Database host name (default: 'localhost')"
      end

      def self.process(opts)
        options = {
          :dbname   => opts.fetch("dbname", ""),
          :user     => opts.fetch("user", ""),
          :password => opts.fetch("password", ""),
          :host     => opts.fetch("host", "")
        }

        # Do the magic!
      end
    end
  end
end
{% endhighlight %}

Let's go through this quickly.

### `self.require_deps`

This function is called before you run your importer to make sure all the necessary gem dependencies are installed on the user's system.

### `self.specify_options`

The `specify_options` function is passed `c`, which is the `Mercenary::Command` instance for this importer. It allows you to specify the right options for your importer to be used with the command-line interface for your importer. `jekyll-import` sets up everything else – just specify these options and you're golden.

### `self.process`

Where the magic happens! This method should read from your *Columbus* source, then output a Jekyll site.

### Optional: `self.validate`

This function is entirely optional, but allows for some validation of the options. This method allows you to validate the options in any way you wish. For example:

{% highlight ruby %}
def self.validate(opts)
  abort "Specify a username!" if opts["username"].nil?
  abort "Your username must be a number." unless opts["username"].match(%r!\A\d+\z!)
end
{% endhighlight %}

Once you have your importer working (test with `script/console`), then you're ready to add **documentation**. Add your new file:
`./docs/_importers/columbus.md`. Take a look at one of the other importers as an example. You just add basic usage and you're golden.

All set? Add everything to a branch on your fork of `jekyll-import` and
[submit a pull request](https://github.com/jekyll/jekyll-import/compare/).  
Thank you!
