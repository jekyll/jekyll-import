require "helper"
require "htmlentities"

class TestWordpressMigrator < Test::Unit::TestCase
  should "clean slashes from slugs" do
    test_title = "blogs part 1/2"
    assert_equal("blogs-part-1-2", Importers::WordPress.sluggify(test_title))
  end
end
