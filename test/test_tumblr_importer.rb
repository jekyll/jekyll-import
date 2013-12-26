require 'helper'
require 'json'

class TestTumblrImporter < Test::Unit::TestCase

	context "A Tumblr blog" do
		setup do
      Importers::Tumblr.require_deps
			@jsonPayload = '{"tumblelog":{"title":"JekyllImport","description":"Jekyll Importer Test.","name":"JekyllImport","timezone":"Canada\/Atlantic","cname":"https://github.com/jekyll/jekyll-import/","feeds":[]},"posts-start":0,"posts-total":"1","posts-type":false,"posts":[{"id":54759400073,"url":"https:\/\/github.com\/post\/54759400073","url-with-slug":"http:\/\/github.com\/post\/54759400073\/jekyll-test","type":"regular","date-gmt":"2013-07-06 16:27:23 GMT","date":"Sat, 06 Jul 2013 13:27:23","bookmarklet":null,"mobile":null,"feed-item":"","from-feed-id":0,"unix-timestamp":1373128043,"format":"html","reblog-key":"0L6yPcHr","slug":"jekyll-test","regular-title":"Jekyll: Test","regular-body":"<p>Testing...<\/p>","tags":["jekyll"]}]}'
			@posts = JSON.parse(@jsonPayload)
		end

		should "have a post" do
			assert_equal(1, @posts["posts"].size)
    end

    should "have a regular post" do
    	assert_equal("regular", @posts['posts'][0]['type'])
    end

    should "convert post into hash" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	refute_nil(batch, "a batch with a valid post should exist")
    end

    should "have a hash with a valid name" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	assert_equal("2013-07-06-jekyll-test.html", batch[0][:name])
    end

    should "have a hash with a valid layout" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	assert_equal("post", batch[0][:header]['layout'])
    end

    should "have a hash with a valid title" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	assert_equal("Jekyll: Test", batch[0][:header]['title'])
    end

    should "have a hash with valid tags" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	assert_equal("jekyll", batch[0][:header]['tags'][0])
    end

    should "have a hash with valid content" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	assert_equal("<p>Testing...</p>", batch[0][:content])
    end

    should "have a hash with a valid url" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	assert_equal("https://github.com/post/54759400073", batch[0][:url])
    end

    should "have a hash with a valid slug" do
    	batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    	assert_equal("http://github.com/post/54759400073/jekyll-test", batch[0][:slug])
    end
	end

  context "A Tumblr photo blog" do
    setup do
      @jsonPhotoPayload = '{"tumblelog":{"title":"jekyll-test","description":"","name":"jekyll-test","timezone":"US\/Eastern","cname":false,"feeds":[]},"posts-start":0,"posts-total":"2","posts-type":false,"posts":[{"id":59226212476,"url":"http:\/\/jekyll-test.tumblr.com\/post\/59226212476","url-with-slug":"http:\/\/jekyll-test.tumblr.com\/post\/59226212476\/testing-multiple-photo-blog-posts","type":"photo","date-gmt":"2013-08-24 20:37:34 GMT","date":"Sat, 24 Aug 2013 16:37:34","bookmarklet":null,"mobile":null,"feed-item":"","from-feed-id":0,"unix-timestamp":1377376654,"format":"html","reblog-key":"CTkEpLrW","slug":"testing-multiple-photo-blog-posts","photo-caption":"<p>testing multiple photo blog posts<\/p>","width":"500","height":"500","photo-url-1280":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg","photo-url-500":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg","photo-url-400":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_400.jpg","photo-url-250":"http:\/\/24.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_250.jpg","photo-url-100":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_100.jpg","photo-url-75":"http:\/\/24.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_75sq.jpg","photos":[{"offset":"o1","caption":"","width":"500","height":"500","photo-url-1280":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg","photo-url-500":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_500.jpg","photo-url-400":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_400.jpg","photo-url-250":"http:\/\/24.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_250.jpg","photo-url-100":"http:\/\/31.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_100.jpg","photo-url-75":"http:\/\/24.media.tumblr.com\/9c7a3d2a18322ed8720eb2efefe91542\/tumblr_ms1ymmMFhF1sgzdxzo1_75sq.jpg"},{"offset":"o2","caption":"","width":"804","height":"732","photo-url-1280":"http:\/\/24.media.tumblr.com\/deb244a5beaae6e32301c06eb32f39d9\/tumblr_ms1ymmMFhF1sgzdxzo2_1280.jpg","photo-url-500":"http:\/\/24.media.tumblr.com\/deb244a5beaae6e32301c06eb32f39d9\/tumblr_ms1ymmMFhF1sgzdxzo2_500.jpg","photo-url-400":"http:\/\/24.media.tumblr.com\/deb244a5beaae6e32301c06eb32f39d9\/tumblr_ms1ymmMFhF1sgzdxzo2_400.jpg","photo-url-250":"http:\/\/24.media.tumblr.com\/deb244a5beaae6e32301c06eb32f39d9\/tumblr_ms1ymmMFhF1sgzdxzo2_250.jpg","photo-url-100":"http:\/\/31.media.tumblr.com\/deb244a5beaae6e32301c06eb32f39d9\/tumblr_ms1ymmMFhF1sgzdxzo2_100.jpg","photo-url-75":"http:\/\/31.media.tumblr.com\/deb244a5beaae6e32301c06eb32f39d9\/tumblr_ms1ymmMFhF1sgzdxzo2_75sq.jpg"}],"tags":["jekyll"]},{"id":59226098458,"url":"http:\/\/jekyll-test.tumblr.com\/post\/59226098458","url-with-slug":"http:\/\/jekyll-test.tumblr.com\/post\/59226098458\/kitty-with-toy","type":"photo","date-gmt":"2013-08-24 20:36:09 GMT","date":"Sat, 24 Aug 2013 16:36:09","bookmarklet":null,"mobile":null,"feed-item":"","from-feed-id":0,"unix-timestamp":1377376569,"format":"html","reblog-key":"UwhVmPot","slug":"kitty-with-toy","photo-caption":"<p>kitty with toy<\/p>","width":"351","height":"600","photo-url-1280":"http:\/\/24.media.tumblr.com\/51a0da0c6fb64291508ef43fbf817085\/tumblr_ms1yk9QKGh1sgzdxzo1_400.jpg","photo-url-500":"http:\/\/24.media.tumblr.com\/51a0da0c6fb64291508ef43fbf817085\/tumblr_ms1yk9QKGh1sgzdxzo1_400.jpg","photo-url-400":"http:\/\/24.media.tumblr.com\/51a0da0c6fb64291508ef43fbf817085\/tumblr_ms1yk9QKGh1sgzdxzo1_400.jpg","photo-url-250":"http:\/\/31.media.tumblr.com\/51a0da0c6fb64291508ef43fbf817085\/tumblr_ms1yk9QKGh1sgzdxzo1_250.jpg","photo-url-100":"http:\/\/24.media.tumblr.com\/51a0da0c6fb64291508ef43fbf817085\/tumblr_ms1yk9QKGh1sgzdxzo1_100.jpg","photo-url-75":"http:\/\/31.media.tumblr.com\/51a0da0c6fb64291508ef43fbf817085\/tumblr_ms1yk9QKGh1sgzdxzo1_75sq.jpg","photos":[]}]}'
      @posts = JSON.parse(@jsonPhotoPayload)
    end
    should "import a post with multiple photos" do
      batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
      assert_match(/tumblr_ms1ymmMFhF1sgzdxzo1_500\.jpg/, batch[0][:content])
      assert_match(/tumblr_ms1ymmMFhF1sgzdxzo2_1280\.jpg/, batch[0][:content])
    end
    should "import a post with a single photo" do
      batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
      assert_match(/tumblr_ms1yk9QKGh1sgzdxzo1_400\.jpg/, batch[1][:content])
    end
  end
end