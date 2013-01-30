$:.unshift File.expand_path("../lib", File.dirname(__FILE__)) # load from jekyll-import/lib

require 'helper'
require 'jekyll/importers/wordpress'
require 'htmlentities'

class TestWordpressMigrator < Test::Unit::TestCase
  should "clean slashes from slugs" do
    test_title = "blogs part 1/2"
    assert_equal("blogs-part-1-2", Jekyll::WordPress.sluggify(test_title))
  end
end
