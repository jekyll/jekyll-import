require "helper"

class TestUtil < Test::Unit::TestCase
  should ".wpautop (wordpress auto-paragraphs)" do
    original = "this is a test\n<p>and it works</p>"
    expected = "<p>this is a test</p>\n<p>and it works</p>\n"
    assert_equal(expected, Util.wpautop(original))
  end

  should ".wpautop is escapes backslash" do
    original = "<pre>/(?<word>\\w+) \\k<word>/</pre>"
    expected = "<pre>/(?<word>\\w+) \\k<word>/</pre>\n"
    assert_equal(expected, Util.wpautop(original))
  end
end
