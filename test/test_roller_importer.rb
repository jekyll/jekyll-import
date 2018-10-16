require "helper"
require "htmlentities"

class TestRollerImporter < Test::Unit::TestCase
  should "clean slashes from slugs" do
    test_title = "blogs part 1/2"
    assert_equal("blogs-part-1-2", Importers::Roller.sluggify(test_title))
  end
end
