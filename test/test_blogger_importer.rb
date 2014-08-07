require 'helper'
require 'tempfile'

class TestBloggerImporter < Test::Unit::TestCase

  should "requires source option" do
    assert_raise(RuntimeError) do
      Importers::Blogger.validate({})
    end
    assert_raise(RuntimeError) do
      Importers::Blogger.validate('source' => nil)
    end
    assert_raise(Errno::ENOENT) do
      Importers::Blogger.validate('source' => "---not-exists-file-#{$$}.xml")
    end
    assert_nothing_raised do
      Tempfile.open('blog-foobar.xml') do |file|
        Importers::Blogger.validate('source' => file.path)
      end
    end
  end

  context "broken file" do
    should "raise an error on parse" do
      Tempfile.open('blog-broken.xml') do |file|
        file << ">>>This is not a XML file.<<<\n"
        file.rewind

        assert_raises(REXML::ParseException) do
          Importers::Blogger.process('source' => file.path)
        end
      end

      Tempfile.open('blog-broken.xml') do |file|
        file << "<aaa><bbb></bbb></aaa" # broken XML
        file.rewind

        assert_raises(REXML::ParseException) do
          Importers::Blogger.process('source' => file.path)
        end
      end
    end

  end

  context "the in-elem-entry-to-post-data converter" do

    listener = nil

    setup do
      listener = Importers::Blogger::BloggerAtomStreamListener.new
    end

    should "return nil if wrong" do
      listener.instance_variable_set(:@in_entry_elem, nil)
      assert_equal(nil, listener.get_post_data_from_in_entry_elem_info())
      listener.instance_variable_set(:@in_entry_elem, {})
      assert_equal(nil, listener.get_post_data_from_in_entry_elem_info())
      listener.instance_variable_set(:@in_entry_elem, {:meta => { :kind => 'not a post' }})
      assert_equal(nil, listener.get_post_data_from_in_entry_elem_info())
    end

    should "raise an error if original_url not exists" do
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => { :kind => 'post' }
      })
      assert_raises(RuntimeError) do
        listener.get_post_data_from_in_entry_elem_info()
      end

      listener.instance_variable_set(:@in_entry_elem, {
        :meta => { :kind => 'post', :original_url => 'http://foobar.blogspot.com/yyyy/mm/foobar.html' }
      })
      assert_nothing_raised(RuntimeError) do
        listener.get_post_data_from_in_entry_elem_info()
      end
    end

    should "raise an error if original_url not exists" do
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => { :kind => 'post' }
      })
      assert_raises(RuntimeError) do
        listener.get_post_data_from_in_entry_elem_info()
      end
    end

    should "generate header hash" do
      published = '1900-01-01T00:00:00'
      updated = '1900-01-01T00:00:01'
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind => 'post',
          :published => published,
          :updated => updated,
          :category => %w[a b c],
          :id => "id-#{$$}",
          :title => "<< title >>",
          :content_type => 'text/html',
          :original_url => 'http://foobar.blogspot.com/1900/01/foobar.html',
        },
        :body => ''
      })
      post_data = listener.get_post_data_from_in_entry_elem_info()

      assert_equal(published, post_data[:header]['date'])
      assert_equal(%w[a b c], post_data[:header]['tags'])
      assert_equal("<< title >>", post_data[:header]['title'])

      assert_equal("id-#{$$}", post_data[:header]['blogger_id'])
      assert_equal('http://foobar.blogspot.com/1900/01/foobar.html', post_data[:header]['blogger_orig_url'])
    end

    should "not generate header hash items if the associated options are specified" do
      published = '1900-01-01T00:00:00'
      updated = '1900-01-01T00:00:01'
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind => 'post',
          :published => published,
          :updated => updated,
          :category => %w[a b c],
          :id => "id-#{$$}",
          :title => "<< title >>",
          :content_type => 'text/html',
          :original_url => 'http://foobar.blogspot.com/1900/01/foobar.html',
        },
        :body => ''
      })
      listener.use_tags = false
      listener.leave_blogger_info = false
      post_data = listener.get_post_data_from_in_entry_elem_info()

      assert_equal(published, post_data[:header]['date'])
      assert(!post_data[:header].include?('tags'))
      assert_equal("<< title >>", post_data[:header]['title'])

      assert(! post_data[:header].include?('blogger_id'))
      assert(! post_data[:header].include?('blogger_orig_url'))
    end

    should "generate body" do
      published = '1900-01-01T00:00:00'
      updated = '1900-01-01T00:00:01'
      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind => 'post',
          :published => published,
          :updated => updated,
          :content_type => 'text/html',
          :original_url => 'http://foobar.blogspot.com/1900/01/foobar.html',
        },
        :body => 'foobar'
      })
      post_data = listener.get_post_data_from_in_entry_elem_info()
      assert_equal('foobar', post_data[:body])

      listener.instance_variable_set(:@in_entry_elem, {
        :meta => {
          :kind => 'post',
          :published => published,
          :updated => updated,
          :content_type => 'text/html',
          :original_url => 'http://foobar.blogspot.com/1900/01/foobar.html',
        },
        :body => '{% {{ foobar }} %}'
      })
      post_data = listener.get_post_data_from_in_entry_elem_info()
      assert_equal('{{ "{%" }} {{ "{{" }} foobar }} %}', post_data[:body])
    end

  end

end
