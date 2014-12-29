## 0.5.3 / 2014-12-29

### Bug Fixes

  * Blogger: Fix draft importing. (#175)

### Site Enhancements

  * Add link to another third-party importer. (#172)

## 0.5.2 / 2014-12-03

### Bug Fixes

  * WordPress: Use `nil` instead of `""` for default socket (#170)
  * Tumblr: Set title to `"no title"` if no title available (#168)

## 0.5.1 / 2014-11-03

### Bug Fixes

  * Fixes for Behance import file (#167)

## 0.5.0 / 2014-09-19

### Minor Enhancements

  * Add Blogger (blogspot.com) importer (#162)

### Development Fixes

  * Remove all comments from the Ruby classes. (#159)
  * Remove a bunch of useless stuff from the Rakefile

## 0.4.1 / 2014-07-31

### Bug Fixes

  * Update WordPress importer to use `table_prefix` everywhere (#154)
  * Add `date` to WordPressDotCom importer output (#152)

### Site Enhancements

  * Update site to use Jekyll 2.2 (#157)

## 0.4.0 / 2014-06-29

### Minor Enhancements

  * Add easyblog importer (#136)
  * WordPress: import draft posts into `_drafts` folder (#147)
  * Be really permissive about which Jekyll version to use

### Bug Fixes

  * Tumblr: Photo posts with multiple photos will now all import (#145)

### Site Enhancements

  * Fix table prefix key in WordPress docs. (#150)

### Development Fixes

  * Add GitHub `script/*` conventions for easy pick-up. (#146)

## 0.3.0 / 2014-05-23

### Minor Enhancements

  * Import WordPress.org `author` data as hash (#139)
  * Add `socket` option to the WordPress importer (#140)
  * Allow the CSV importer to skip writing front matter (#143)
  * WordPress.com: Download images locally and update links to them (#134)
  * WordPress: Import WP pages as proper Jekyll pages instead of as posts (#137)

### Bug Fixes

  * Replace errant `continue` expression with the valid `next` expression (#133)

## 0.2.0 / 2014-03-16

### Major Enhancements
  * Add comments to MovableType importer (#66)
  * Support auto-paragraph Wordpress convention (#125)

### Minor Enhancements
  * Extract author info from wordpress XML files (#131)

### Bug Fixes
  * Require YAML library in Enki importer (#112)
  * Fix !ruby/string:Sequel::SQL::Blob error in MT excerpts (#113)
  * Drupal6: Ensure post "tags" is "", never nil (#117)
  * Fixes a bug where the Tumblr importer would write posts with `nil`
    content (#118)
  * Change Drupal7 layout to `post` rather than `default` (#124)
  * WordPress: Use explicit `#to_s` when outputting post dates (#129)

### Site Enhancements
  * Fixed error in quickstart code, added required design changes/reflow (#120)
  * Fix example parameter names for Tumblr importer (#122)
  * Add note to WordPress installer docs page that indicates what the importer
    does and doesn't do. (#127)

### Development Fixes
  * Bring gemspec into the 2010's (#130)

## 0.1.0 / 2013-12-18

### Major Enhancements
  * Add 'Ghost' importer (#100)
  * Add 'Behance' importer (#46, #104)
  * Add the optional ability to include images in a posterous migration (#5)
  * Posterous archive (unzipped directory) importer added (#12)
  * Improve MovableType importer (#13)
  * Add an importer for Google Reader blog exports (#36)
  * Remove dependency on html2text in the tumblr importer (#33)
  * Add the ability to import .jrnl files (#51)
  * Handle missing gems a bit more gracefully (#59)

### Minor Enhancements
  * Add date and redirection pages for blogs imported from Tumblr (#54)
  * Various Tumblr Enhancements (#27)
  * Adding tags to Typo and forcing their encoding to UTF-8 (#11)
  * S9Y Importer: specify data source using --source option (#18)
  * Add taxonomy (`tags`) to Drupal6 migration (#15)
  * Differentiate between categories and tags in the WordpressDotCom
    importer (#31)
  * Use tumblr slug for post is available, use that instead (#39, #40)
  * Drupal 7 importer should use latest revision of a post (#38)
  * Improve the handling of tags in the Drupal 6 importer. Tags with
    spaces are handled now and the importer doesn't eat tags anymore. (#42)
  * Upgrade to `jekyll ~> 1.3` and `safe_yaml ~> 0.9.7`
  * Add license to gemspec (#83)
  * Add an `Importer.run` method for easy invocation (#88)

### Bug Fixes
  * Remove usage of `Hash#at` in Tumblr importer (#14)
  * Force encoding of Drupal 6.x titles to UTF-8 (#22)
  * Update wordpressdotcom.rb to use its method parameter correctly (#24)
  * Use MySQL2 adapter for WordPress importer to fix broken front-matter (#20)
  * Fix WordPress import initialize parameters due to new Jekyll setup (#19)
  * Fixed misspelling in method name (#17)
  * Fix Drupal 7 importer so it compares node ID's properly between `node` and
    `field_data_body` tables (#38)
  * Fix prefix replacement for Drupal6 (#41)
  * Fix an exception when a Movable Type blog did not have additional
    entry text (#45)
  * Create `_layouts/` before writing refresh.html in Drupal migrators (#48)
  * Fix bug where post date in `MT` importer was not imported for older versions
    of MT sites (#62)
  * Fix interface of importers' `#process` method (#69)
  * RSS importer should specify `--source` option (#81)
  * Fix fetching of parameters from options hash (#86)
  * Drupal6: Fix NoMethodError on untagged post (#93)
  * S9Y: Use RSS parser from `rss` package, not the RSS importer (#102)
  * Support as much of the current Commander interface as possible (#103)

### Site Enhancements
  * Add the site (#87)

### Development Fixes
  * Update usage docs in RSS importer (#35)
  * Added initial version of a test case for Tumblr (#43)
  * Remove some outdated comments in the Drupal migrators (#50)
  * Update the README to be more informative (#52)
  * Add comment to Wordpress importer on how to install mysql with
    MacPorts (#56)
  * Correcting the homepage URL so links from rubygems.org will work (#63)
