# encoding: UTF-8

require "helper"

class TestCSVImporter < Test::Unit::TestCase
  sample_row = [
    "My Title",
    "/2015/05/05/hi.html",
    "Welcome to Jekyll!\n\nI am a post body.",
    "2015-01-10",
    "markdown",
  ]

  context "CSVPost" do
    should "parse published_at to DateTime" do
      post = Importers::CSV::CSVPost.new(sample_row)
      assert post.published_at.is_a?(DateTime), "post.published_at should be a DateTime"
      assert_equal "2015-01-10", post.published_at.strftime("%Y-%m-%d")
    end

    should "pull in metadata properly" do
      post = Importers::CSV::CSVPost.new(sample_row)
      assert_equal sample_row[0], post.title
      assert_equal sample_row[1], post.permalink
      assert_equal sample_row[2], post.body
      assert_equal sample_row[4], post.markup
    end

    should "correctly construct source filename" do
      post = Importers::CSV::CSVPost.new(sample_row)
      assert_equal "2015-01-10-hi.markdown", post.filename
    end
  end

  context "CSV importer" do
    should "write post to proper place" do
      FileUtils.mkdir_p "tmp/_posts"
      Dir.chdir("tmp") do
        post = Importers::CSV::CSVPost.new(sample_row)
        Importers::CSV.write_post(post, {})
        output_filename = "_posts/2015-01-10-hi.markdown"
        assert File.exist?(output_filename), "Post should be written."

        lines = IO.readlines(output_filename)
        assert_equal "---\n", lines[0]
        assert_equal "layout: post\n", lines[1]
        assert_equal "title: My Title\n", lines[2]
        assert_equal "date: '2015-01-10T00:00:00+00:00'\n", lines[3]
        assert_match %r!permalink: "?\/2015\/05\/05\/hi\.html"?!, lines[4]
        assert_equal "---\n", lines[5]
        assert_equal "Welcome to Jekyll!\n", lines[6]
        assert_equal "\n", lines[7]
        assert_equal "I am a post body.\n", lines[8]
        File.unlink(output_filename)
      end
    end
  end
end
