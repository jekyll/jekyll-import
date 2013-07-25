require 'helper'
require 'json'

class TestTumblrImporter < Test::Unit::TestCase

	context "A Tumblr blog" do
		setup do
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
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	refute_nil(batch, "a batch with a valid post should exist")	    
	    end

	    should "have a hash with a valid name" do
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	assert_equal("2013-07-06-jekyll-test.html", batch[0][:name])
	    end

	    should "have a hash with a valid layout" do
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	assert_equal("post", batch[0][:header]['layout'])
	    end

	    should "have a hash with a valid title" do
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	assert_equal("Jekyll: Test", batch[0][:header]['title'])
	    end

	    should "have a hash with valid tags" do
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	assert_equal("jekyll", batch[0][:header]['tags'][0])
	    end

	    should "have a hash with valid content" do
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	assert_equal("<p>Testing...</p>", batch[0][:content])
	    end

	    should "have a hash with a valid url" do
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	assert_equal("https://github.com/post/54759400073", batch[0][:url])
	    end

	    should "have a hash with a valid slug" do
	    	batch = @posts["posts"].map { |post| JekyllImport::Tumblr.post_to_hash(post, 'html') }
	    	assert_equal("http://github.com/post/54759400073/jekyll-test", batch[0][:slug])
	    end
	end
end