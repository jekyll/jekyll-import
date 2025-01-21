require "helper"
require "tmpdir"

Importers::WordpressDotCom.require_deps

class TestWordpressDotComMigrator < Test::Unit::TestCase
  should "clean slashes from slugs" do
    test_title = "blogs part 1/2"
    assert_equal("blogs-part-1-2", Importers::WordpressDotCom.sluggify(test_title))
  end

  should "generate the correct site" do
    xml_path = File.expand_path("mocks/sitetitle.wordpress.2025-01-19.000.xml", __dir__)
    assert File.exist?(xml_path), "Expect xml file to exist"
    tmpdir = Dir.mktmpdir
    Dir.chdir(tmpdir) do
      Jekyll.logger = ::Logger.new(File.open("output.log", "w"))
      JekyllImport::Importers::WordpressDotCom.process({"source" => xml_path})
      Jekyll.logger = Jekyll::Stevenson.new
    end

    # The old export produced the following files:
    # .
    # ├── _attachments
    # │   ├── a-bright-night-sky-full-of-stars-and-the-milky.html
    # │   ├── a-bright-night-sky-full-of-stars-viewed-from-a-2.html
    # │   ├── a-bright-night-sky-full-of-stars-viewed-from-a.html
    # │   ├── placeholder-image-2.html
    # │   ├── placeholder-image-3.html
    # │   └── placeholder-image.html
    # ├── _pages
    # │   └── 2025-01-19-about.html
    # ├── _posts
    # │   ├── 2025-01-18-adaptive-advantage.html
    # │   ├── 2025-01-18-beyond-the-obstacle.html
    # │   ├── 2025-01-18-blog-post-1.html
    # │   ├── 2025-01-18-collaboration-magic.html
    # │   ├── 2025-01-18-growth-unlocked.html
    # │   ├── 2025-01-18-teamwork-triumphs.html
    # │   └── 2025-01-18-the-art-of-connection.html
    # ├── _wp_global_styless
    # │   └── 2025-01-18-wp-global-styles-pub%2ftwentytwentyfour.html
    # ├── _wp_navigations
    # │   └── 2025-01-18-navigation.html
    # └── assets
    #     └── 2025
    #         └── 01
    #             └── a-bright-night-sky-full-of-stars-and-the-milky.png
    assert_path_exist File.expand_path("assets/2025/01/a-bright-night-sky-full-of-stars-and-the-milky.png", tmpdir)

    jekyllbot_author_data = {
      "login"        => "jekyllbot",
      "email"        => "jekyllbot@gmail.com",
      "display_name" => "jekyllbot",
      "first_name"   => "Jekyllbot",
      "last_name"    => "Hyde",
    }

    assert_path_exist File.expand_path("_pages/2025-01-19-about.html", tmpdir)
    page_content = File.read(File.expand_path("_pages/2025-01-19-about.html", tmpdir))
    page_front_matter = page_content.match(/^(---\n.*?---\n)/m)[0]
    page_data = YAML.safe_load(page_front_matter)
    assert_equal true, page_data["published"]
    assert_equal "/about/", page_data["permalink"]
    assert_equal jekyllbot_author_data, page_data["author"]

    assert_path_exist File.expand_path("_posts/2025-01-18-blog-post-1.html", tmpdir)
    post_content = File.read(File.expand_path("_posts/2025-01-18-blog-post-1.html", tmpdir))
    post_front_matter = post_content.match(/^(---\n.*?---\n)/m)[0]
    post_data = YAML.safe_load(post_front_matter)
    assert_equal true, post_data["published"]
    assert_equal "Blog Post 1", post_data["title"]
    assert_equal ["Foo"], post_data["categories"]
    assert_equal ["code", "ruby", "ship", "stars"], post_data["tags"]
    assert_equal jekyllbot_author_data, post_data["author"]
    assert_equal "/2025/01/18/blog-post-1/", post_data["permalink"]
    assert_equal "101042542514", post_data["meta"]["_publicize_job_id"]
    assert_includes post_content, "<p>This is a blog post.</p>"
    assert_includes post_content, '<figure class="wp-block-image size-full"><img src="{{site.baseurl}}/assets/2025/01/a-bright-night-sky-full-of-stars-and-the-milky.png" alt="" class="wp-image-19"></figure>'
    assert_includes post_content, <<~HTML
<pre class="wp-block-code"><code>query = "Generate an image of a night sky above the ocean with a wooden fishing ship on the water."
puts "Executing query: \#{query}"
puts AIBot.new(query).execute.result</code></pre>
HTML

    assert_path_exist File.expand_path("_posts/2025-01-18-the-art-of-connection.html", tmpdir)
    post_content = File.read(File.expand_path("_posts/2025-01-18-the-art-of-connection.html", tmpdir))
    post_front_matter = post_content.match(/^(---\n.*?---\n)/m)[0]
    post_data = YAML.safe_load(post_front_matter)
    assert_equal "In the ever-evolving world, the art of forging genuine connections remains timeless. Whether it’s with colleagues, clients, or partners, establishing a genuine rapport paves the way for collaborative success.", post_data["excerpt"]

    # Assert all posts are imported.
    [
      "2025-01-18-adaptive-advantage.html",
      "2025-01-18-collaboration-magic.html",
      "2025-01-18-beyond-the-obstacle.html",
      "2025-01-18-growth-unlocked.html",
      "2025-01-18-teamwork-triumphs.html"
    ].each do |post_slug|
      assert_path_exist File.expand_path("_posts/"+post_slug, tmpdir)
    end
  end
end

class TestWordpressDotComItem < Test::Unit::TestCase
  should "extract an item's title" do
    node = Nokogiri::XML('
      <item>
        <title>Dear Science</title>
      </item>').at_css("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("Dear Science", item.title)
  end

  should "use post_name for the permalink_title if it's there" do
    node = Nokogiri::XML('
    <rss xmlns:wp="http://wordpress.org/export/1.2/">
      <item>
        <wp:post_name>cookie-mountain</wp:post_name>
        <title>Dear Science</title>
      </item>
    </rss>').at_css("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("cookie-mountain", item.permalink_title)
  end

  should "sluggify title for the permalink_title if post_name is empty" do
    node = Nokogiri::XML('
    <rss xmlns:wp="http://wordpress.org/export/1.2/">
      <item>
        <wp:post_name></wp:post_name>
        <title>Dear Science</title>
      </item>
    </rss>').at_css("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("dear-science", item.permalink_title)
  end

  should "return nil for the excerpt, if it's missing" do
    node = Nokogiri::XML('
    <rss xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/">
      <item>
        <excerpt:encoded><![CDATA[]]></excerpt:encoded>
      </item>
    </rss>').at_css("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal(nil, item.excerpt)
  end

  should "extract the excerpt as plaintext, if it's present" do
    node = Nokogiri::XML('
    <rss xmlns:excerpt="http://wordpress.org/export/1.2/excerpt/">
      <item>
        <excerpt:encoded><![CDATA[...this one weird trick.]]></excerpt:encoded>
      </item>
    </rss>').at_css("item")

    item = Importers::WordpressDotCom::Item.new(node)
    assert_equal("...this one weird trick.", item.excerpt)
  end
end

class TestWordpressDotComPublishedItem < TestWordpressDotComItem
  def node
    Nokogiri::XML('
    <rss xmlns:wp="http://wordpress.org/export/1.2/">
      <item>
        <title>PostTitle</title>
        <link>https://www.example.com/post/123/post-title/</link>
        <wp:post_name>post-name</wp:post_name>
        <wp:post_type>post</wp:post_type>
        <wp:status>publish</wp:status>
        <wp:post_date>2015-01-23 08:53:47</wp:post_date>
      </item>
    </rss>').at("item")
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
    Nokogiri::XML('
    <rss xmlns:wp="http://wordpress.org/export/1.2/">
      <item>
        <wp:post_name>post-name</wp:post_name>
        <wp:post_type>post</wp:post_type>
        <wp:status>draft</wp:status>
        <wp:post_date>0000-00-00 00:00:00</wp:post_date>
      </item>
    </rss>').at_css("item")
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
