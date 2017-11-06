require "helper"
require "date"

class TestMTMigrator < Test::Unit::TestCase
  def stub_entry_row(overrides = {})
    now = DateTime.now
    # These properties corespond to the column names for the mt_entry table
    {
      :entry_id             => 1,
      :entry_blog_id        => 1,
      :entry_status         => Importers::MT::STATUS_PUBLISHED,
      :entry_author_id      => 1,
      :entry_allow_comments => 0,
      :entry_allow_pings    => 0,
      :entry_convert_breaks => "__default__",
      :entry_category_id    => nil,
      :entry_title          => "Lorem Ipsum",
      :entry_excerpt        => "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.",
      :entry_text           => "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Vivamus vitae risus vitae lorem iaculis placerat.",
      :entry_text_more      => "Aliquam sit amet felis. Etiam congue. Donec risus risus, pretium ac, tincidunt eu, tempor eu, quam. Morbi blandit mollis magna.",
      :entry_to_ping_urls   => "",
      :entry_pinged_urls    => nil,
      :entry_keywords       => "",
      :entry_tangent_cache  => nil,
      :entry_created_on     => now,
      :entry_modified_on    => now,
      :entry_created_by     => nil,
      :entry_modified_by    => 1,
      :entry_basename       => "lorem_ipsum",
      :entry_atom_id        => "tag:www.example.com,#{now.year}:/blog/1.4",
      :entry_week_number    => "#{now.year}#{now.cweek}".to_i,
      :entry_ping_count     => 0,
      :entry_comment_count  => 0,
      :entry_authored_on    => now,
      :entry_template_id    => nil,
      :entry_class          => "entry",
    }.merge(overrides)
  end

  should "set layout to post" do
    assert_equal("post", Importers::MT.post_metadata(stub_entry_row)["layout"])
  end

  should "extract authored_on as date, formatted as 'YYYY-MM-DD HH:MM:SS Z'" do
    post = stub_entry_row
    expected_date = post[:entry_authored_on].strftime("%Y-%m-%d %H:%M:%S %z")
    assert_equal(expected_date, Importers::MT.post_metadata(post)["date"])
  end

  should "extract entry_excerpt as excerpt" do
    post = stub_entry_row
    assert_equal(post[:entry_excerpt], Importers::MT.post_metadata(post)["excerpt"])
  end

  should "extract entry_id as mt_id" do
    post = stub_entry_row(:entry_id => 123)
    assert_equal(123, Importers::MT.post_metadata(post)["mt_id"])
  end

  should "extract entry_title as title" do
    post = stub_entry_row
    assert_equal(post[:entry_title], Importers::MT.post_metadata(post)["title"])
  end

  should "set published to false if entry_status is not published" do
    post = stub_entry_row(:entry_status => Importers::MT::STATUS_DRAFT)
    assert_equal(false, Importers::MT.post_metadata(post)["published"])
  end

  should "not set published if entry_status is published" do
    post = stub_entry_row(:entry_status => Importers::MT::STATUS_PUBLISHED)
    assert_equal(nil, Importers::MT.post_metadata(post)["published"])
  end

  should "include entry_text" do
    post = stub_entry_row
    assert Importers::MT.post_content(post).include?(post[:entry_text])
  end

  should "include entry_text_more" do
    post = stub_entry_row
    assert Importers::MT.post_content(post).include?(post[:entry_text_more])
  end

  should "include a <!--MORE--> separator when there is entry_text_more" do
    post = stub_entry_row(:entry_text_more => "Some more entry")
    assert Importers::MT.post_content(post).include?(Importers::MT::MORE_CONTENT_SEPARATOR)
  end

  should "not include a <!--MORE--> separator when there is no entry_text_more" do
    post = stub_entry_row(:entry_text_more => "")
    assert !Importers::MT.post_content(post).include?(Importers::MT::MORE_CONTENT_SEPARATOR)
  end

  should "include the entry_authored_on date in the file name" do
    post = stub_entry_row(:entry_authored_on => Time.parse("2013-01-02 00:00:00 -00:00").utc)
    assert Importers::MT.post_file_name(post).include?("2013-01-02")
  end

  should "include entry_basename in the file name" do
    post = stub_entry_row(:entry_basename => "my_blog-entry")
    assert Importers::MT.post_file_name(post).include?("my_blog-entry")
  end
end
