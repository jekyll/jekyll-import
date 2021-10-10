## HEAD

### Bug Fixes

  * Replace decode with decode_www_form_component (#438)
  * Change data[author] to a string scalar (#419)

### Minor Enhancements

  * Add support for Podcast RSS feed imports (#413)
  * s9y-db importer permalink, tag, excerpt, and semantic HTML improvements (#392)
  * drupal6: retain url_alias.dst as permalink in imported nodes (#393)
  * Create drupal8.rb (#405)
  * Drupal aliases now respect the &#39;source&#39; config (#454)

### Development Fixes

  * Clean up code to make Rubocop happy (#441)
  * Set up GH Action for Continuous Integration (#449)
  * Refactor Blogger importer with guard clauses (#452)

### Documentation

  * Update csv.md (#444)
  * Update Enki website link (#457)

## 0.20.0 / 2020-09-08

### Minor Enhancements

  * Pluxml (#430)

### style

  * style: Target Ruby 2.4 (#432)

### Bug Fixes

  * Fix &#39;can&#39;t add a new key into hash during iteration&#39; error (#434)
  * WordpressDotCom: put downloaded assets into /year/month subfolders to reduce clashes (#436)

## 0.19.2 / 2020-03-07

### Documentation

  * Add install additional gems note (#403)

### Development Fixes

  * Remove deprecated use of fastercsv (#423)

## 0.19.1 / 2019-11-05

### Documentation

  * Fix link for Posterous importer (#415)

### Bug Fixes

  * Fix wrong option in self.process_tags (#417)

## 0.19.0 / 2019-06-24

### Bug Fixes

  * Extract encoded_content from feed (#409)
  * Check whether option[&#34;tag&#34;] is null or empty value (#411)

### Minor Enhancements

  * Add Dotclear importer (#414)
  * Slugify post name with Jekyll::Utils.slugify (#410)

## 0.18.1 / 2019-03-23

### Bug Fixes

  * Re-introduce Ruby 2.3 support and test Jekyll 3.7+ (#406)

## 0.18.0 / 2019-03-22

### Minor Enhancements

  * Import Wordpress permalinks (#395)

### Bug Fixes

  * ghost.db stores timestamps in ms, not seconds. Fixed the ghost importer. (#396)
  * Fix WP pre tag util raise error when value includes regexp (#401)

### Development Fixes

  * Drop support for Ruby 2.3
  * Allow Jekyll v4 (still alpha)

## 0.17.1 / 2018-12-23

### Bug Fixes

  * Replace URI.parse.open with OpenURI.open_uri (#389)

## 0.17.0 / 2018-12-20

### Bug Fixes

  * Unfreeze strings in importers that modify literals (#381)
  * Patch missing per_page bug in Tumblr importer (#383)

### Minor Enhancements

  * remove extra / if passed with --url (#378)
  * Convert Tumblr content to Markdown when opted for (#384)
  * Convert HTML to MD with ReverseMarkdown instead (#386)

### Development Fixes

  * Prettify JSON payloads in test_tumblr_importer (#385)

## 0.16.0 / 2018-11-04

### Development Fixes

  * chore(deps): rubocop-jekyll 0.3 (#370)

### Documentation

  * docs: avoid error message (#374)

### Minor Enhancements

  * refactor: Roller improvements and tests (#371)

## 0.15.0 / 2018-10-17

### Minor Enhancements

  * Add roller importer (#363)
  * Allow additional options to RSS import (#307)

### Bug Fixes

  * Use mysql by default in Drupal importers. (#347)
  * WordPress: add missing site prefix in user table (#343)
  * Drupal: add option to configure port. Add missing prefix to taxonomy tables. (#349)
  * Movable type: fix column name typo (#351)

### Development Fixes

  * Replace uninitialized constant with alternative (#358)
  * chore(deps): fix gem build warnings (#361)
  * Remove cyclic require of import command (#359)
  * style: ignore Lint/Loop for tumblr (#360)
  * style: inherit rubocop-jekyll's rules (#357)
  * Refactor Tumblr Importer (#362)

### Documentation

  * Update Documentation for Contributing to project (#366)

## 0.14.0 / 2018-02-03

### Development Fixes

  * Security: Fix alert on activesupport (#332)
  * Test against Ruby 2.5 (#336)

### Minor Enhancements

  * Add support for Drupal 7 installations with PostgreSQL database (#331)

## 0.13.0 / 2017-11-05

### Minor Enhancements

  * WordPress: add port options for mysql db connection (#311)
  * Ghost: import drafts & pages, and fix issue with date extraction (#304)
  * Add parent_id to wordpressdotcom importer (#301)
  * RSS: add &#34;tag&#34; option to add a tag to all posts (#306)
  * WordPressDotCom: import post passwords (#302)
  * Joomla3: Use mysql2 instead of mysql (#309)
  * Joomla: Add option to specify the MySQL port (#310)

### Bug Fixes

  * Drupal 7: Remove uneeded double quote in SQL query (#287)
  * Drupal 7: Fixes SQL grouping error (#289)
  * S9y: Add port to db options & pull out `entries.extended` field (#299)
  * Blogger: replace special characters with hyphens in the post name (#280)
  * WordPress: fix variable name for `more_anchor` (#305)
  * WordPress: replace was backwards, broke end tags (#292)

### Development Fixes

  * Updating Ruby and Jekyll versions for testing (#290)
  * Modernize Travis configuration (#317)
  * Define path with __dir__ (#316)
  * Appease Rubocop (#318)
  * Stop testing against Jekyll 2.5 (#323)

### Site Enhancements

  * Corrected Joomla3 importer name and clarified "category" field (#286)
  * Fixed style issues on HTTPS site (#296)
  * Change broken link for "A great article" (#294)

### Documentation

  * Add the new port setting to the Wordpress importer docs (#312)

## 0.12.0 / 2016-11-28

  * Joomla: require the `mysql` gem (#197)
  * Tumblr: improve compatibility with Jekyll 3 (#239)
  * tumblr: only append to content if its truthy (#265)
  * Add S9y database importer (#259)
  * Add functionality for importing Blogger comments (#258)
  * joomla: use & require mysql2 instead of mysql (#255)
  * Tumblr: close conversation HTML tags in the right order (#266)
  * Tumblr: Fixing double-read and off-by-one error (#253)
  * Clean up the Drupal importers (#235)
  * DrupalCommon: centralize defaults & use config for layouts dir (#267)
  * Tumblr: save images in binary mode (#278)
  * Tumblr: fix creation of rewrite rules (#283)

### Development Fixes

  * Fix Travis CI build (#273)

### Site Enhancements

  * Fix for misnamed Joomla3 module in docs (#271)

## 0.11.0 / 2016-06-27

### Bug Fixes

  * Drupal 6 importer depends on mysql. (#242)
  * Tumblr: Update range of JSON readlines to extract JSON from JS (Tumblr may have changed structure of JSON) (#243)
  * Tumblr: look up beginning and end of JSON dynamically (#249)
  * Tumblr: fix stripping of JSONP characters from feed (#251)

### Site Enhancements

  * Correct "How to Contribute" link (#244)
  * Correct "our community forum" link (#246)

### Development Fixes

  * Add rubocop (#248)

## 0.10.0 / 2016-01-16

  * Drupal 7: Allow importing any node type via the `types` option (#230)
  * Drupal 6: Allow importing any node type via the `types` option (#231)
  * Drupal 7: Add author and nid fields to import. (#237)
  * MT: allow use of SQLite for installation. (#234)
  * CSV: parse the post using a class which errors on missing data. (#238)

## 0.9.0 / 2015-11-04

  * WordPress.com: Now follows 'safe' http to https redirections for images (#223)
  * Blogger: Decode URI encoded multibyte file names (#221)
  * Tumblr: Encode source URL before parsing (#217)
  * Tumblr: If invalid post slug, fall back to the post ID (#210)
  * Add Joomla 3 importer (#184)
  * Joomla 1: various fixes related to correct import (#188)
  * Travis: test against Jekyll 2 & 3 with all supported Rubies. (#227)
  * MovableType: Add support for importing from PostgreSQL-backed sites (#224)

## 0.8.0 / 2015-09-13

  * WordPress: Add `site_prefix` to support WP multi-site (#203)
  * WordPress: Add `extension` option to support different output file extensions (#208)
  * WordPress.com: Fix `assets_folder` to include leading slash. (#212)
  * WordPress.com: Write dateless posts to `_drafts` (#213)
  * Wordpress.com: Fix a few issues introduced by #213 (#218)

## 0.7.1 / 2015-05-06

  * RSS: Require all of `rss` to get atom parser. (#196)

## 0.7.0 / 2015-05-06

  * Tumblr: check for content when parsing a video caption to avoid Nil error (#179)
  * Tumblr: pass `redirect_dir` so it's accessible from `add_syntax_highlights` (#191)
  * Drupal 7: Fix Title extraction bug where it's read as binary (#192)
  * WordPress: update docs to explictly define dependencies. (#190)

## 0.6.0 / 2015-03-07

### Minor Enhancements

  * Drupal 7: use the `body_summary` field as an `excerpt` if it's available (#176)
  * WordPress.com: Extract post excerpt (#189)

### Bug Fixes

  * Drupal 7: Remove unused `nid` from MySQL `SELECT` (#177)

### Development Fixes

  * Updated the LICENSE file to the "standard" formatting (#178)

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
  * Fixes a bug where the Tumblr importer would write posts with `nil` content (#118)
  * Change Drupal7 layout to `post` rather than `default` (#124)
  * WordPress: Use explicit `#to_s` when outputting post dates (#129)

### Site Enhancements

  * Fixed error in quickstart code, added required design changes/reflow (#120)
  * Fix example parameter names for Tumblr importer (#122)
  * Add note to WordPress installer docs page that indicates what the importer does and doesn't do. (#127)

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
  * Differentiate between categories and tags in the WordpressDotCom importer (#31)
  * Use tumblr slug for post is available, use that instead (#39, #40)
  * Drupal 7 importer should use latest revision of a post (#38)
  * Improve the handling of tags in the Drupal 6 importer. Tags with spaces are handled now and the importer doesn't eat tags anymore. (#42)
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
  * Fix Drupal 7 importer so it compares node ID's properly between `node` and `field_data_body` tables (#38)
  * Fix prefix replacement for Drupal6 (#41)
  * Fix an exception when a Movable Type blog did not have additional entry text (#45)
  * Create `_layouts/` before writing refresh.html in Drupal migrators (#48)
  * Fix bug where post date in `MT` importer was not imported for older versions of MT sites (#62)
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
  * Add comment to Wordpress importer on how to install mysql with MacPorts (#56)
  * Correcting the homepage URL so links from rubygems.org will work (#63)
