require 'rubygems'
require 'posterous-archive'
require 'tempfile'
require 'helper'

class TestPosterousArchiveImporter < Test::Unit::TestCase
  should "Parse a dummy posterous html file" do
    puts 'testing'
    dummytitle    = "DummyPostTitle"
    dummydate     = "January 1 2000,  12:00 AM"
    dummyauthor   = "DummyAuthor"
    dummycontent  = "DummyContent"
    dummyposttext = 
      ["<html>",
       "<body>",
         "<div class='post'>",
         "<div class='post_header'>",
           "<h3>%s</h3>" % dummytitle,
           "<div class='post_info'>",
             "<span class='post_time'>%s</span>" % dummydate,
             "<span class='author'>%s</span>" % dummyauthor,
           "</div>",
         "</div>",
         "<div class='post_body'>%s</div>" % dummycontent,
       "</body>",
       "</html>"]

    Tempfile.open(['post', '.html']) do |f|

      f.write(dummyposttext.join("\n"))
      f.flush()

      post = Jekyll::PosterousArchive.loadpost(f.path)

      assert_equal(post["title"],  dummytitle)
      assert_equal(post["date"],   dummydate)
      assert_equal(post["body"],   dummycontent)
      assert_equal(post["images"], [])

      print post
    end
  end

  should "Convert a hash containing posterous information into a hash containing jekyll post information" do

    dummytitle    = "DummyPostTitle"
    dummydate     = "January 1 2000,  12:00 AM"
    dummycontent  = "DummyContent"
    dateobj       = Date.parse(dummydate)
    dummyslug     = dummytitle.downcase
    dummyname     = '%04d-%02d-%02d-%s' % 
      [dateobj.year, dateobj.month, dateobj.day, dummyslug]

    dummyPost = Hash.new
    dummyPost["title"]  = dummytitle
    dummyPost["date"]   = dummydate
    dummyPost["body"]   = dummycontent
    dummyPost["images"] = []

    jpost = Jekyll::PosterousArchive.convertpost(dummyPost)

    assert_equal(jpost["title"],   dummytitle)
    assert_equal(jpost["date"],    dateobj)
    assert_equal(jpost["slug"],    dummyslug)
    assert_equal(jpost["name"],    dummyname)
    assert_equal(jpost["content"], dummycontent)
    assert_equal(jpost["images"],  [])
  end
end
