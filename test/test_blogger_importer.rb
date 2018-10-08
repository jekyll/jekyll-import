require "helper"
require "tempfile"
require "tmpdir"

class TestBloggerImporter < Test::Unit::TestCase
  should "requires source option" do
    assert_raise(RuntimeError) do
      Importers::Blogger.validate({})
    end
    assert_raise(RuntimeError) do
      Importers::Blogger.validate("source" => nil)
    end
    assert_raise(Errno::ENOENT) do
      Importers::Blogger.validate("source" => "---not-exists-file-#{$PROCESS_ID}.xml")
    end
    assert_nothing_raised do
      Tempfile.open("blog-foobar.xml") do |file|
        Importers::Blogger.validate("source" => file.path)
      end
    end
  end

  context "broken file" do
    should "raise an error on parse" do
      Tempfile.open("blog-broken.xml") do |file|
        file << ">>>This is not a XML file.<<<\n"
        file.rewind

        assert_raises(REXML::ParseException) do
          Importers::Blogger.process("source" => file.path)
        end
      end

      Tempfile.open("blog-broken.xml") do |file|
        file << "<aaa><bbb></bbb></aaa" # broken XML
        file.rewind

        assert_raises(REXML::ParseException) do
          Importers::Blogger.process("source" => file.path)
        end
      end
    end
  end

  context "postprocessing" do
    should "replace internal link if specified" do
      Dir.mktmpdir do |tmpdir|
        orig_pwd = Dir.pwd
        begin
          Dir.chdir(tmpdir)

          post0_src = <<EOF
---
---
<a href="/1900/02/post1.html">aaa</a>
EOF
          post0_replacement = <<EOF
---
---
<a href="{{ site.baseurl }}{% post_url 1900-02-01-post1 %}">aaa</a>
EOF
          post1_src = <<EOF
---
---
<a href="http://foobar.blogspot.com/1900/01/post0.html">aaa</a>
<a href="http://external.blogspot.com/1900/01/post0.html">bbb</a>
EOF
          post1_replacement = <<EOF
---
---
<a href="{{ site.baseurl }}{% post_url 1900-01-01-post0 %}">aaa</a>
<a href="http://external.blogspot.com/1900/01/post0.html">bbb</a>
EOF
          FileUtils.mkdir_p("_posts")
          File.open("_posts/1900-01-01-post0.html", "w") { |f| f << post0_src }
          File.open("_posts/1900-02-01-post1.html", "w") { |f| f << post1_src }

          Importers::Blogger.postprocess("replace-internal-link" => false)

          StringIO.open(post0_src, "r") do |expected|
            File.open("_posts/1900-01-01-post0.html", "r") do |actual|
              assert_equal(expected.read, actual.read)
            end
          end
          StringIO.open(post1_src, "r") do |expected|
            File.open("_posts/1900-02-01-post1.html", "r") do |actual|
              assert_equal(expected.read, actual.read)
            end
          end

          Importers::Blogger.postprocess("replace-internal-link" => true, "original-url-base" => "http://foobar.blogspot.com")

          StringIO.open(post0_replacement, "r") do |expected|
            File.open("_posts/1900-01-01-post0.html", "r") do |actual|
              assert_equal(expected.read, actual.read)
            end
          end
          StringIO.open(post1_replacement, "r") do |expected|
            File.open("_posts/1900-02-01-post1.html", "r") do |actual|
              assert_equal(expected.read, actual.read)
            end
          end
        ensure
          Dir.chdir(orig_pwd)
        end
      end
    end
  end

  context "the xml parser" do
    listener = nil

    setup do
      listener = Importers::Blogger::BloggerAtomStreamListener.new
      class << listener
        # overwrite with mock function
        def post_data_from_in_entry_elem_info
          @entry_elem_info_array = [] unless @entry_elem_info_array
          @entry_elem_info_array << @in_entry_elem.dup

          false # to avoid generate post data
        end

        attr_reader :entry_elem_info_array
      end
    end

    should "read entries" do
      xml_str = <<EOD
<?xml version="1.0"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:georss="http://www.georss.org/georss" xmlns:gd="http://schemas.google.com/g/2005" xmlns:thr="http://purl.org/syndication/thread/1.0">
  <!-- snip -->
  <entry>
    <published>1900-01-01T00:00:00.000Z</published>
    <updated>1900-01-01T01:00:00.000Z</updated>
    <category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/blogger/2008/kind#template"/>
    <title type="text">template.title</title>
    <content type="text">*snip*</content>
    <!-- snip -->
    <author>
      <name>template.author.name</name>
      <!-- snip -->
    </author>
  </entry>
  <entry>
    <published>1900-02-01T00:00:00.000Z</published>
    <updated>1900-02-01T01:00:00.000Z</updated>
    <category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/blogger/2008/kind#post"/>
    <category scheme="http://www.blogger.com/atom/ns#" term="post0.atom.ns.0"/>
    <title type="text">post0.title</title>
    <content type="html">&lt;p&gt;*post0.content*&lt;/p&gt;</content>
    <link rel="alternate" type="text/html" href="http://foobar.blogspot.com/1900/02/post0.link.html" title="post0.link"/>
    <!-- snip -->
    <author>
      <name>post0.author.name</name>
      <!-- snip -->
    </author>
    <media:thumbnail xmlns:media="http://search.yahoo.com/mrss/" url="post0.thumbnail.url"/>
  </entry>
  <entry>
    <published>1900-03-01T00:00:00.000Z</published>
    <updated>1900-03-01T01:00:00.000Z</updated>
    <category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/blogger/2008/kind#post"/>
    <category scheme="http://www.blogger.com/atom/ns#" term="post1.atom.ns.0"/>
    <category scheme="http://www.blogger.com/atom/ns#" term="post1.atom.ns.1"/>
    <title type="text">post1.title</title>
    <content type="html">&lt;p&gt;*post1.content*&lt;/p&gt;</content>
    <link rel="alternate" type="text/html" href="http://foobar.blogspot.com/1900/03/post1.link.html" title="post1.link"/>
    <!-- snip -->
    <author>
      <name>post1.author.name</name>
      <!-- snip -->
    </author>
    <!--media:thumbnail xmlns:media="http://search.yahoo.com/mrss/" url="post1.thumbnail.url"/-->
  </entry>
  <entry>
    <published>1900-04-01T00:00:00.000Z</published>
    <updated>1900-04-01T01:00:00.000Z</updated>
    <category scheme="http://schemas.google.com/g/2005#kind" term="http://schemas.google.com/blogger/2008/kind#post"/>
    <category scheme="http://www.blogger.com/atom/ns#" term="post2.atom.ns.0"/>
    <category scheme="http://www.blogger.com/atom/ns#" term="post2.atom.ns.1"/>
    <title type="text">post2.title</title>
    <content type="html">&lt;p&gt;*post2.content*&lt;/p&gt;</content>
    <link rel="replies" type="text/html" href="http://foobar.blogspot.com/1900/04/post2.link.html#comment-form" title="post2.comments"/>
    <!-- snip -->
    <author>
      <name>post2.author.name</name>
      <!-- snip -->
    </author>
    <!--media:thumbnail xmlns:media="http://search.yahoo.com/mrss/" url="post2.thumbnail.url"/-->
  </entry>
</feed>
EOD
      StringIO.open(xml_str, "r") do |f|
        REXML::Parsers::StreamParser.new(f, listener).parse
      end

      assert_equal(3, listener.entry_elem_info_array.length)

      assert_equal(%w(post0.atom.ns.0), listener.entry_elem_info_array[0][:meta][:category])
      assert_equal("post", listener.entry_elem_info_array[0][:meta][:kind])
      assert_equal("html", listener.entry_elem_info_array[0][:meta][:content_type])
      assert_equal("http://foobar.blogspot.com/1900/02/post0.link.html", listener.entry_elem_info_array[0][:meta][:original_url])
      assert_equal("1900-02-01T00:00:00.000Z", listener.entry_elem_info_array[0][:meta][:published])
      assert_equal("1900-02-01T01:00:00.000Z", listener.entry_elem_info_array[0][:meta][:updated])
      assert_equal("post0.title", listener.entry_elem_info_array[0][:meta][:title])
      assert_equal("<p>*post0.content*</p>", listener.entry_elem_info_array[0][:body])
      assert_equal("post0.author.name", listener.entry_elem_info_array[0][:meta][:author])
      assert_equal("post0.thumbnail.url", listener.entry_elem_info_array[0][:meta][:thumbnail])

      assert_equal(%w(post1.atom.ns.0 post1.atom.ns.1), listener.entry_elem_info_array[1][:meta][:category])
      assert_equal("post", listener.entry_elem_info_array[1][:meta][:kind])
      assert_equal("html", listener.entry_elem_info_array[1][:meta][:content_type])
      assert_equal("http://foobar.blogspot.com/1900/03/post1.link.html", listener.entry_elem_info_array[1][:meta][:original_url])
      assert_equal("1900-03-01T00:00:00.000Z", listener.entry_elem_info_array[1][:meta][:published])
      assert_equal("1900-03-01T01:00:00.000Z", listener.entry_elem_info_array[1][:meta][:updated])
      assert_equal("post1.title", listener.entry_elem_info_array[1][:meta][:title])
      assert_equal("<p>*post1.content*</p>", listener.entry_elem_info_array[1][:body])
      assert_equal("post1.author.name", listener.entry_elem_info_array[1][:meta][:author])
      assert_equal(nil, listener.entry_elem_info_array[1][:meta][:thumbnail])

      assert_equal(%w(post2.atom.ns.0 post2.atom.ns.1), listener.entry_elem_info_array[2][:meta][:category])
      assert_equal("post", listener.entry_elem_info_array[2][:meta][:kind])
      assert_equal("html", listener.entry_elem_info_array[2][:meta][:content_type])
      assert_equal("http://foobar.blogspot.com/1900/04/post2.link.html", listener.entry_elem_info_array[2][:meta][:original_url])
      assert_equal("1900-04-01T00:00:00.000Z", listener.entry_elem_info_array[2][:meta][:published])
      assert_equal("1900-04-01T01:00:00.000Z", listener.entry_elem_info_array[2][:meta][:updated])
      assert_equal("post2.title", listener.entry_elem_info_array[2][:meta][:title])
      assert_equal("<p>*post2.content*</p>", listener.entry_elem_info_array[2][:body])
      assert_equal("post2.author.name", listener.entry_elem_info_array[2][:meta][:author])
      assert_equal(nil, listener.entry_elem_info_array[2][:meta][:thumbnail])
    end
  end

  context "the in-elem-entry-to-post-data converter" do
    listener = nil

    setup do
      listener = Importers::Blogger::BloggerAtomStreamListener.new
    end

    should "return nil if wrong" do
      listener.instance_variable_set(:@in_entry_elem, nil)
      assert_equal(nil, listener.post_data_from_in_entry_elem_info )
      listener.instance_variable_set(:@in_entry_elem, {})
      assert_equal(nil, listener.post_data_from_in_entry_elem_info )
      listener.instance_variable_set(:@in_entry_elem, { :meta => { :kind => "not a post" } })
      assert_equal(nil, listener.post_data_from_in_entry_elem_info )
    end

    should "raise an error if original_url not exists" do
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind      => "post",
          :published => "1900-01-01T00:00:00",
        },
      })
      assert_raises(RuntimeError) do
        listener.post_data_from_in_entry_elem_info
      end

      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind         => "post",
          :published    => "1900-01-01T00:00:00",
          :original_url => "http://foobar.blogspot.com/yyyy/mm/foobar.html",
        },
      })
      assert_nothing_raised(RuntimeError) do
        listener.post_data_from_in_entry_elem_info
      end
    end

    should "return nil if the kind is not set to post" do
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => { :kind => "foo" },
      })
      assert_nil(listener.post_data_from_in_entry_elem_info )
    end

    should "generate header hash" do
      published = "1900-01-01T00:00:00"
      updated = "1900-01-01T00:00:01"
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind         => "post",
          :published    => published,
          :updated      => updated,
          :category     => %w(a b c),
          :id           => "id-#{$PROCESS_ID}",
          :title        => "<< title >>",
          :content_type => "text/html",
          :original_url => "http://foobar.blogspot.com/1900/01/foobar.html",
        },
        :body => "",
      })
      post_data = listener.post_data_from_in_entry_elem_info

      assert_equal(published, post_data[:header]["date"])
      assert_equal(%w(a b c), post_data[:header]["tags"])
      assert_equal("<< title >>", post_data[:header]["title"])

      assert_equal("id-#{$PROCESS_ID}", post_data[:header]["blogger_id"])
      assert_equal("http://foobar.blogspot.com/1900/01/foobar.html", post_data[:header]["blogger_orig_url"])

      assert_equal("http://foobar.blogspot.com", listener.original_url_base)
    end

    should "not generate header hash items if the associated options are specified" do
      published = "1900-01-01T00:00:00"
      updated = "1900-01-01T00:00:01"
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind         => "post",
          :published    => published,
          :updated      => updated,
          :category     => %w(a b c),
          :id           => "id-#{$PROCESS_ID}",
          :title        => "<< title >>",
          :content_type => "text/html",
          :original_url => "http://foobar.blogspot.com/1900/01/foobar.html",
        },
        :body => "",
      })
      listener.leave_blogger_info = false
      post_data = listener.post_data_from_in_entry_elem_info

      assert_equal(published, post_data[:header]["date"])
      assert_equal(%w(a b c), post_data[:header]["tags"])
      assert_equal("<< title >>", post_data[:header]["title"])

      assert(!post_data[:header].include?("blogger_id"))
      assert(!post_data[:header].include?("blogger_orig_url"))

      assert_equal("http://foobar.blogspot.com", listener.original_url_base)
    end

    should "generate body" do
      published = "1900-01-01T00:00:00"
      updated = "1900-01-01T00:00:01"
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind         => "post",
          :published    => published,
          :updated      => updated,
          :content_type => "text/html",
          :original_url => "http://foobar.blogspot.com/1900/01/foobar.html",
        },
        :body => "foobar",
      })
      post_data = listener.post_data_from_in_entry_elem_info
      assert_equal("foobar", post_data[:body])

      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind         => "post",
          :published    => published,
          :updated      => updated,
          :content_type => "text/html",
          :original_url => "http://foobar.blogspot.com/1900/01/foobar.html",
        },
        :body => "{% {{ foobar }} %}",
      })
      post_data = listener.post_data_from_in_entry_elem_info
      assert_equal('{{ "{%" }} {{ "{{" }} foobar }} %}', post_data[:body])
    end
  end
end
