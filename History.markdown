## HEAD

### Major Enhancements
  * Add the optional ability to include images in a posterous migration (#5)
  * Posterous archive (unzipped directory) importer added (#12)
  * Improve MovableType importer (#13)
  * Add an importer for Google Reader blog exports (#36)
  * Remove dependency on html2text in the tumblr importer (#33)

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

### Site Enhancements

### Development Fixes
  * Update usage docs in RSS importer (#35)
  * Added initial version of a test case for Tumblr (#43)
  * Remove some outdated comments in the Drupal migrators (#50)
  * Update the README to be more informative (#52)
  * Add comment to Wordpress importer on how to install mysql with
    MacPorts (#56)
