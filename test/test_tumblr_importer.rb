require "helper"
require "json"

class TestTumblrImporter < Test::Unit::TestCase
  context "A Tumblr blog" do
    setup do
      Importers::Tumblr.require_deps
      @jsonPayload = <<~PAYLOAD
        {
          "tumblelog"   : {
            "title"       : "JekyllImport",
            "description" : "Jekyll Importer Test.",
            "name"        : "JekyllImport",
            "timezone"    : "Canada/Atlantic",
            "cname"       : "https://github.com/jekyll/jekyll-import/",
            "feeds"       : []
          },
          "posts-start" : 0,
          "posts-total" : "2",
          "posts-type"  : false,
          "posts"       : [
            {
              "id"             : 54759400073,
              "url"            : "https://github.com/post/54759400073",
              "url-with-slug"  : "http://github.com/post/54759400073/jekyll-test",
              "type"           : "regular",
              "date-gmt"       : "2013-07-06 16:27:23 GMT",
              "date"           : "Sat, 06 Jul 2013 13:27:23",
              "bookmarklet"    : null,
              "mobile"         : null,
              "feed-item"      : "",
              "from-feed-id"   : 0,
              "unix-timestamp" : 1373128043,
              "format"         : "html",
              "reblog-key"     : "0L6yPcHr",
              "slug"           : "jekyll-test",
              "regular-title"  : "Jekyll: Test",
              "regular-body"   : "<p>Testing...</p>",
              "tags"           : ["jekyll"]
            },
            {
              "id"             : "71845593082",
              "url"            : "http://example.com/post/71845593082",
              "url-with-slug"  : "http://example.com/post/71845593082/knock-knock",
              "type"           : "answer",
              "date-gmt"       : "2014-01-01 14:08:45 GMT",
              "date"           : "Wed, 01 Jan 2014 09:08:45",
              "bookmarklet"    : 0,
              "mobile"         : 0,
              "feed-item"      : "",
              "from-feed-id"   : 0,
              "unix-timestamp" : 1388585325,
              "format"         : "html",
              "reblog-key"     : "jPfWHFnT",
              "slug"           : "knock-knock",
              "question"       : "Knock knock?",
              "answer"         : "<p>Who is there?</p>"
            }
          ]
        }
      PAYLOAD
      @posts = JSON.parse(@jsonPayload)
      @payload = "var tumblr_api_read = #{@jsonPayload}"
      @batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, "html") }
    end

    should "extract json properly" do
      assert_equal @posts, Importers::Tumblr.send(:extract_json, @payload)
    end

    should "have a post" do
      assert_equal(2, @posts["posts"].size)
    end

    should "convert post into hash" do
      refute_nil(@batch, "a batch with a valid post should exist")
    end

    context "url handling" do
      should "handle multiple // in the passed url" do
        blog_url = "http://myblog.com///"
        just_url = Importers::Tumblr.send(:api_feed_url, blog_url, 0).split("?").first
        assert_equal "http://myblog.com/api/read/json/", just_url
      end

      should "handle pagination" do
        blog_url = "http://myblog.com///"
        assert_equal "http://myblog.com/api/read/json/?num=25&start=125",
          Importers::Tumblr.send(:api_feed_url, blog_url, 5, 25)
      end
    end

    context "post" do
      should "have a corresponding type" do
        assert_equal("regular", @posts["posts"][0]["type"])
      end

      should "have a hash with a valid name" do
        assert_equal("2013-07-06-jekyll-test.html", @batch[0][:name])
      end

      should "have a hash with a valid layout" do
        assert_equal("post", @batch[0][:header]["layout"])
      end

      should "have a hash with a valid title" do
        assert_equal("Jekyll: Test", @batch[0][:header]["title"])
      end

      should "have a hash with valid tags" do
        assert_equal("jekyll", @batch[0][:header]["tags"][0])
      end

      should "have a hash with valid content" do
        assert_equal("<p>Testing...</p>", @batch[0][:content])
      end

      should "have a hash with a valid url" do
        assert_equal("https://github.com/post/54759400073", @batch[0][:url])
      end

      should "have a hash with a valid slug" do
        assert_equal("http://github.com/post/54759400073/jekyll-test", @batch[0][:slug])
      end
    end

    context "answer" do
      should "have a corresponding type" do
        assert_equal("answer", @posts["posts"][1]["type"])
      end

      should "have a hash with a valid name" do
        assert_equal("2014-01-01-knock-knock.html", @batch[1][:name])
      end

      should "have a hash with a valid layout" do
        assert_equal("post", @batch[1][:header]["layout"])
      end

      should "have a hash with a valid title" do
        assert_equal("Knock knock?", @batch[1][:header]["title"])
      end

      should "have a hash with valid tags" do
        assert_equal([], @batch[1][:header]["tags"])
      end

      should "have a hash with valid content" do
        assert_equal("<p>Who is there?</p>", @batch[1][:content])
      end

      should "have a hash with a valid url" do
        assert_equal("http://example.com/post/71845593082", @batch[1][:url])
      end

      should "have a hash with a valid slug" do
        assert_equal("http://example.com/post/71845593082/knock-knock", @batch[1][:slug])
      end
    end
  end

  context "a Tumblr photo blog" do
    setup do
      @jsonPhotoPayload = <<~PAYLOAD
        {
          "tumblelog"   : {
            "title"       : "jekyll-test",
            "description" : "",
            "name"        : "jekyll-test",
            "timezone"    : "US/Eastern",
            "cname"       : false,
            "feeds"       : []
          },
          "posts-start" : 0,
          "posts-total" : "2",
          "posts-type"  : false,
          "posts"       : [
            {
              "id"             : 59226212476,
              "url"            : "http://jekyll-test.tumblr.com/post/59226212476",
              "url-with-slug"  : "http://jekyll-test.tumblr.com/post/59226212476/testing-multiple-photo-blog-posts",
              "type"           : "photo",
              "date-gmt"       : "2013-08-24 20:37:34 GMT",
              "date"           : "Sat, 24 Aug 2013 16:37:34",
              "bookmarklet"    : null,
              "mobile"         : null,
              "feed-item"      : "",
              "from-feed-id"   : 0,
              "unix-timestamp" : 1377376654,
              "format"         : "html",
              "reblog-key"     : "CTkEpLrW",
              "slug"           : "testing-multiple-photo-blog-posts",
              "photo-caption"  : "<p>testing multiple photo blog posts</p>",
              "width"          : "500",
              "height"         : "500",
              "photo-url-1280" : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg",
              "photo-url-500"  : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg",
              "photo-url-400"  : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_400.jpg",
              "photo-url-250"  : "http://24.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_250.jpg",
              "photo-url-100"  : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_100.jpg",
              "photo-url-75"   : "http://24.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_75sq.jpg",
              "photos"         : [
                {
                  "offset"         : "o1",
                  "caption"        : "",
                  "width"          : "500",
                  "height"         : "500",
                  "photo-url-1280" : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg",
                  "photo-url-500"  : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg",
                  "photo-url-400"  : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_400.jpg",
                  "photo-url-250"  : "http://24.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_250.jpg",
                  "photo-url-100"  : "http://31.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_100.jpg",
                  "photo-url-75"   : "http://24.media.tumblr.com/9c7a3d2a18322ed8720eb2efefe91542/tumblr_ms1ymmMFhF1sgzdxzo1_75sq.jpg"
                },
                {
                  "offset"         : "o2",
                  "caption"        : "",
                  "width"          : "804",
                  "height"         : "732",
                  "photo-url-1280" : "http://24.media.tumblr.com/deb244a5beaae6e32301c06eb32f39d9/tumblr_ms1ymmMFhF1sgzdxzo2_1280.jpg",
                  "photo-url-500"  : "http://24.media.tumblr.com/deb244a5beaae6e32301c06eb32f39d9/tumblr_ms1ymmMFhF1sgzdxzo2_500.jpg",
                  "photo-url-400"  : "http://24.media.tumblr.com/deb244a5beaae6e32301c06eb32f39d9/tumblr_ms1ymmMFhF1sgzdxzo2_400.jpg",
                  "photo-url-250"  : "http://24.media.tumblr.com/deb244a5beaae6e32301c06eb32f39d9/tumblr_ms1ymmMFhF1sgzdxzo2_250.jpg",
                  "photo-url-100"  : "http://31.media.tumblr.com/deb244a5beaae6e32301c06eb32f39d9/tumblr_ms1ymmMFhF1sgzdxzo2_100.jpg",
                  "photo-url-75"   : "http://31.media.tumblr.com/deb244a5beaae6e32301c06eb32f39d9/tumblr_ms1ymmMFhF1sgzdxzo2_75sq.jpg"
                }
              ],
              "tags"           : ["jekyll"]
            },
            {
              "id"             : 59226098458,
              "url"            : "http://jekyll-test.tumblr.com/post/59226098458",
              "url-with-slug"  : "http://jekyll-test.tumblr.com/post/59226098458/kitty-with-toy",
              "type"           : "photo",
              "date-gmt"       : "2013-08-24 20:36:09 GMT",
              "date"           : "Sat, 24 Aug 2013 16:36:09",
              "bookmarklet"    : null,
              "mobile"         : null,
              "feed-item"      : "",
              "from-feed-id"   : 0,
              "unix-timestamp" : 1377376569,
              "format"         : "html",
              "reblog-key"     : "UwhVmPot",
              "slug"           : "kitty-with-toy",
              "photo-caption"  : "<p>kitty with toy</p>",
              "width"          : "351",
              "height"         : "600",
              "photo-url-1280" : "http://24.media.tumblr.com/51a0da0c6fb64291508ef43fbf817085/tumblr_ms1yk9QKGh1sgzdxzo1_400.jpg",
              "photo-url-500"  : "http://24.media.tumblr.com/51a0da0c6fb64291508ef43fbf817085/tumblr_ms1yk9QKGh1sgzdxzo1_400.jpg",
              "photo-url-400"  : "http://24.media.tumblr.com/51a0da0c6fb64291508ef43fbf817085/tumblr_ms1yk9QKGh1sgzdxzo1_400.jpg",
              "photo-url-250"  : "http://31.media.tumblr.com/51a0da0c6fb64291508ef43fbf817085/tumblr_ms1yk9QKGh1sgzdxzo1_250.jpg",
              "photo-url-100"  : "http://24.media.tumblr.com/51a0da0c6fb64291508ef43fbf817085/tumblr_ms1yk9QKGh1sgzdxzo1_100.jpg",
              "photo-url-75"   : "http://31.media.tumblr.com/51a0da0c6fb64291508ef43fbf817085/tumblr_ms1yk9QKGh1sgzdxzo1_75sq.jpg",
              "photos"         : []
            }
          ]
        }
      PAYLOAD
      @posts = JSON.parse(@jsonPhotoPayload)
    end

    should "import a post with multiple photos" do
      batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, "html") }
      assert_match(%r!tumblr_ms1ymmMFhF1sgzdxzo1_500\.jpg!, batch[0][:content])
      assert_match(%r!tumblr_ms1ymmMFhF1sgzdxzo2_1280\.jpg!, batch[0][:content])
    end
    should "import a post with a single photo" do
      batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, "html") }
      assert_match(%r!tumblr_ms1yk9QKGh1sgzdxzo1_400\.jpg!, batch[1][:content])
    end
  end

  context "Opting to convert html to markdown" do
    should "result in valid Markdown text" do
      input = <<~HTML
        <h1>A Test Post</h1>
        <p>
          This is a paragraph that contains a variety of formatted text.
          Simply put, <b>bold</b> &amp; <strong>strong</strong> appear thicker than the regular
          text. A text in <i>italics</i> denotes <em>emphasis</em> with a slight slant from the
          vertical axis. A <a href="http://example.com">link</a> points to a reference elsewhere
          and is usually underlined.
        </p>
        <p>
          Images are generally embedded by using the <code>&lt;img&gt;</code> tag and render
          directly like this duck: <img src="img/duck.png" alt="Quack!"/>
        </p>
        <p>
          Frais pour l'hiver.
        </p>
      HTML

      output = "# A Test Post\n\nThis is a paragraph that contains a variety of formatted text. " \
               "Simply put, **bold** & **strong** appear thicker than the regular text. A text " \
               "in _italics_ denotes _emphasis_ with a slight slant from the vertical axis. A " \
               "[link](http://example.com) points to a reference elsewhere and is usually under" \
               "lined.\n\nImages are generally embedded by using the `<img>` tag and render " \
               "directly like this duck: ![Quack!](img/duck.png)\n\nFrais pour l'hiver.\n\n"

      assert_equal(output, Importers::Tumblr.html_to_markdown(input))
    end
  end
end
