require 'helper'
require 'time'

class TestJrnlMigrator < Test::Unit::TestCase

  context "jrnl" do
    setup do
      @journal = "2013-09-24 11:36 jrnl test case 1.\nThis is a test case for jekyll-import."
      @entries = @journal.split("\n\n")
      @entry = @entries.first.split("\n")
      @date_length = Time.now().strftime("%Y-%m-%d %H:%M").length
    end

    should "have posts" do
      assert_equal(1, @entries.size)
    end

    should "have content" do
      assert_equal("This is a test case for jekyll-import.", JekyllImport::Jrnl.get_post_content(@entry))
    end

    should "have date" do
      assert_equal("2013-09-24 11:36:00 +0530", "#{JekyllImport::Jrnl.get_date(@entry[0], @date_length)}")
    end

    should "have title" do
      assert_equal("jrnl test case 1.", JekyllImport::Jrnl.get_title(@entry[0], @date_length))
    end

    should "have slug" do
      assert_equal("jrnl-test-case-1", JekyllImport::Jrnl.create_slug(JekyllImport::Jrnl.get_title(@entry[0], @date_length)))
    end

    should "have filename" do
      assert_equal("2013-09-24-jrnl-test-case-1.md", JekyllImport::Jrnl.create_filename(JekyllImport::Jrnl.get_date(@entry[0], @date_length), JekyllImport::Jrnl.create_slug(JekyllImport::Jrnl.get_title(@entry[0], @date_length)), 'md'))
    end

  end
end