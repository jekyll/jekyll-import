require "helper"

class TestWordpressDotComMigrator < Test::Unit::TestCase
  should "clean slashes from slugs" do
    test_title = "blogs part 1/2"
    assert_equal("blogs-part-1-2", Importers::WordpressDotCom.sluggify(test_title))
  end
end

class TestWordpressDotComItem < Test::Unit::TestCase
  should "extract an item's title" do
    node = Hpricot('
      <item>
        <title>Dear Science</title>
      </item>').at("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("Dear Science", item.title)
  end

  should "use post_name for the permalink_title if it's there" do
    node = Hpricot('
      <item>
        <wp:post_name>cookie-mountain</wp:post_name>
        <title>Dear Science</title>
      </item>').at("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("cookie-mountain", item.permalink_title)
  end

  should "sluggify title for the permalink_title if post_name is empty" do
    node = Hpricot('
      <item>
        <wp:post_name></wp:post_name>
        <title>Dear Science</title>
      </item>').at("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("dear-science", item.permalink_title)
  end

  should "return nil for the excerpt, if it's missing" do
    node = Hpricot('
      <item>
        <excerpt:encoded><![CDATA[]]></excerpt:encoded>
      </item>').at("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal(nil, item.excerpt)
  end

  should "extract the excerpt as plaintext, if it's present" do
    node = Hpricot('
      <item>
        <excerpt:encoded><![CDATA[...this one weird trick.]]></excerpt:encoded>
      </item>').at("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("...this one weird trick.", item.excerpt)
  end
end

class TestWordpressDotComPublishedItem < TestWordpressDotComItem
  def node
    Hpricot('
      <item>
        <title>PostTitle</title>
        <link>https://www.example.com/post/123/post-title/</link>
        <wp:post_name>post-name</wp:post_name>
        <wp:post_type>post</wp:post_type>
        <wp:status>publish</wp:status>
        <wp:post_date>2015-01-23 08:53:47</wp:post_date>
      </item>').at("item")
  end

  def item
    Importers::WordpressDotCom::Item.new(node)
  end

  should "extract the date-time the item was published" do
    assert_equal(Time.new(2015, 1, 23, 8, 53, 47), item.published_at)
  end

  should "put the date in the file_name" do
    assert_equal("2015-01-23-post-name.html", item.file_name)
  end

  should "put the file in ./_posts" do
    assert_equal("_posts", item.directory_name)
  end

  should "know its status" do
    assert_equal("publish", item.status)
  end

  should "be published" do
    assert_equal(true, item.published?)
  end

  should "extract the link as a permalink" do
    assert_equal("/post/123/post-title/", item.permalink)
  end
end

class TestWordpressDotComDraftItem < TestWordpressDotComItem
  def node
    Hpricot('
      <item>
        <wp:post_name>post-name</wp:post_name>
        <wp:post_type>post</wp:post_type>
        <wp:status>draft</wp:status>
        <wp:post_date>0000-00-00 00:00:00</wp:post_date>
      </item>').at("item")
  end

  def item
    Importers::WordpressDotCom::Item.new(node)
  end

  should "extract a nil publish-date" do
    assert_equal(nil, item.published_at)
  end

  should "not put the date in the file_name" do
    assert_equal("post-name.html", item.file_name)
  end

  should "put the file in ./_drafts" do
    assert_equal("_drafts", item.directory_name)
  end

  should "know its status" do
    assert_equal("draft", item.status)
  end

  should "not be published" do
    assert_equal(false, item.published?)
  end
end
