require 'helper'
require 'json'

class TestTumblrImporter < Test::Unit::TestCase

  context "A Tumblr blog" do
    setup do
      Importers::Tumblr.require_deps
      @jsonPayload = '{"tumblelog":{"title":"JekyllImport","description":"Jekyll Importer Test.","name":"JekyllImport","timezone":"Canada\/Atlantic","cname":"https://github.com/jekyll/jekyll-import/","feeds":[]},"posts-start":0,"posts-total":"2","posts-type":false,"posts":[{"id":54759400073,"url":"https:\/\/github.com\/post\/54759400073","url-with-slug":"http:\/\/github.com\/post\/54759400073\/jekyll-test","type":"regular","date-gmt":"2013-07-06 16:27:23 GMT","date":"Sat, 06 Jul 2013 13:27:23","bookmarklet":null,"mobile":null,"feed-item":"","from-feed-id":0,"unix-timestamp":1373128043,"format":"html","reblog-key":"0L6yPcHr","slug":"jekyll-test","regular-title":"Jekyll: Test","regular-body":"<p>Testing...<\/p>","tags":["jekyll"]},{"id":"71845593082","url":"http:\/\/example.com\/post\/71845593082","url-with-slug":"http:\/\/example.com\/post\/71845593082\/knock-knock","type":"answer","date-gmt":"2014-01-01 14:08:45 GMT","date":"Wed, 01 Jan 2014 09:08:45","bookmarklet":0,"mobile":0,"feed-item":"","from-feed-id":0,"unix-timestamp":1388585325,"format":"html","reblog-key":"jPfWHFnT","slug":"knock-knock","question":"Knock knock?","answer":"<p>Who is there?<\/p>"}]}'
      @posts = JSON.parse(@jsonPayload)
      @batch = @posts["posts"].map { |post| Importers::Tumblr.post_to_hash(post, 'html') }
    end

    should "have a post" do
      assert_equal(2, @posts["posts"].size)
    end
  
    should "convert post into hash" do
      refute_nil(@batch, "a batch with a valid post should exist")
    end

    context "post" do
      should "have a corresponding type" do
        assert_equal("regular", @posts['posts'][0]['type'])
      end
  
      should "have a hash with a valid name" do
        assert_equal("2013-07-06-jekyll-test.html", @batch[0][:name])
      end
  
      should "have a hash with a valid layout" do
        assert_equal("post", @batch[0][:header]['layout'])
      end
  
      should "have a hash with a valid title" do
        assert_equal("Jekyll: Test", @batch[0][:header]['title'])
      end
  
      should "have a hash with valid tags" do
        assert_equal("jekyll", @batch[0][:header]['tags'][0])
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
        assert_equal("answer", @posts['posts'][1]['type'])
      end
  
      should "have a hash with a valid name" do
        assert_equal("2014-01-01-knock-knock.html", @batch[1][:name])
      end
  
      should "have a hash with a valid layout" do
        assert_equal("post", @batch[1][:header]['layout'])
      end
  
      should "have a hash with a valid title" do
        assert_equal("Knock knock?", @batch[1][:header]['title'])
      end
  
      should "have a hash with valid tags" do
        assert_equal([], @batch[1][:header]['tags'])
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
end
