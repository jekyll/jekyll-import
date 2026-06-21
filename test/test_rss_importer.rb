# frozen_string_literal: true

require "helper"
require "tmpdir"

Importers::RSS.require_deps

class TestRSSImporter < Test::Unit::TestCase
  def described_class
    Importers::RSS
  end

  def feed_path
    File.join(Dir.pwd, "test/mocks/rss_feed.xml")
  end

  # Run the importer inside a throwaway working directory and yield the
  # generated `_posts` files (as a path => contents Hash) to the block.
  def import(options = {})
    source = feed_path
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        described_class.process({ "source" => source }.merge(options))
        posts = Dir.glob("_posts/*").sort.each_with_object({}) do |path, memo|
          memo[path] = File.read(path)
        end
        yield posts
      end
    end
  end

  context "validate" do
    should "abort when no source is given" do
      assert_raises(SystemExit) { described_class.validate({}) }
    end

    should "abort when both tag and extract_tags are given" do
      assert_raises(SystemExit) do
        described_class.validate("source" => feed_path, "tag" => "blog", "extract_tags" => "category")
      end
    end

    should "accept a source on its own" do
      assert_nothing_raised { described_class.validate("source" => feed_path) }
    end
  end

  context "process" do
    should "raise when the source has no parseable RSS" do
      Dir.mktmpdir do |tmpdir|
        empty = File.join(tmpdir, "empty.xml")
        File.write(empty, "<not-a-feed/>")
        assert_raises(RuntimeError) { described_class.process("source" => empty) }
      end
    end

    should "create one post per feed item" do
      import do |posts|
        assert_equal 2, posts.size
      end
    end

    should "name files using the item date and slugified title" do
      import do |posts|
        assert posts.key?("_posts/2022-11-22-first-post.html")
        assert posts.key?("_posts/2022-11-10-second-post-with-spaces.html")
      end
    end

    should "write post front matter and body" do
      import do |posts|
        contents = posts["_posts/2022-11-22-first-post.html"]
        assert_includes contents, "layout: post\n"
        assert_includes contents, "title: First Post\n"
        assert_includes contents, "---\n\nThe quick brown fox jumps over the lazy dog."
      end
    end

    should "not add a canonical_url by default" do
      import do |posts|
        refute_includes posts["_posts/2022-11-22-first-post.html"], "canonical_url"
      end
    end

    should "add the original link as canonical_url when requested" do
      import("canonical_link" => true) do |posts|
        assert_includes posts["_posts/2022-11-22-first-post.html"],
                        "canonical_url: https://example.com/blog/first-post\n"
      end
    end

    should "apply an explicit tag to every post" do
      import("tag" => "blog") do |posts|
        posts.each_value { |contents| assert_includes contents, "tag: blog\n" }
      end
    end

    should "extract tags from the configured item subfield" do
      import("extract_tags" => "category") do |posts|
        assert_includes posts["_posts/2022-11-22-first-post.html"], "tag:\n- ruby\n- jekyll\n"
      end
    end

    should "render an audio element when render_audio is set" do
      import("render_audio" => true) do |posts|
        contents = posts["_posts/2022-11-22-first-post.html"]
        assert_includes contents, %(<source src="https://example.com/audio/first-post.mp3" type="audio/mpeg">)
      end
    end

    should "not render an audio element by default" do
      import do |posts|
        refute_includes posts["_posts/2022-11-22-first-post.html"], "<audio"
      end
    end
  end

  context "get_tags" do
    setup do
      content = File.read(feed_path)
      @item = ::RSS::Parser.parse(content, false).items.first
    end

    should "prefer an explicit tag" do
      assert_equal "blog", described_class.send(:get_tags, @item, "tag" => "blog")
    end

    should "extract and downcase tags from the named subfield" do
      assert_equal %w(ruby jekyll), described_class.send(:get_tags, @item, "extract_tags" => "category")
    end

    should "return nil when there is nothing to tag" do
      assert_nil described_class.send(:get_tags, @item, {})
    end

    should "return nil when the named subfield is absent" do
      assert_nil described_class.send(:get_tags, @item, "extract_tags" => "nonexistent")
    end
  end
end
