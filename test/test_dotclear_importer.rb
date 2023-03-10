# frozen_string_literal: true

require "helper"
require "tempfile"

Importers::Dotclear.require_deps

class TestDotclearImporter < Test::Unit::TestCase
  def described_class
    Importers::Dotclear
  end

  context "Importing with valid export file" do
    setup do
      orig_pwd = Dir.pwd
      @export_file = File.join(orig_pwd, "test/mocks/dotclear.txt")

      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          @asset_file_path = "MiUser/250px-MonaLisaGraffiti.JPG"
          @asset_src_path  = File.join("media_dir", @asset_file_path)

          FileUtils.mkdir_p("media_dir/MiUser")
          File.binwrite(@asset_src_path, "Hello")

          @output = capture_output { described_class.run("datafile" => @export_file, "mediafolder" => "media_dir") }
          @post_path = "_drafts/2017-03-25-welcome-to-dotclear.html"
          @contents = File.read(@post_path)
        end
      end
    end

    should "log export file path" do
      assert_includes @output, "Export File: #{@export_file}"
    end

    should "create post files with front matter and *adjusted* HTML content" do
      assert_includes @output, "Creating: #{@post_path}"
      assert_includes @contents, "---\nlayout: post\ntitle: Welcome to Dotclear!\n"
      assert_includes @contents, "tags:\n- Indiana\n"
      assert_includes @contents, "---\n\n<p style=\"color: blue\">This is your first entry."
      assert_includes @contents, "\n\n<a href=\"/assets/dotclear/MiUser/250px-MonaLisaGraffiti.JPG>\">"
    end

    context "with media files" do
      should "log copied path and destination path" do
        assert_includes @output, "Copying: #{@asset_src_path}"
        assert_includes @output, "To: #{File.join("assets/dotclear", @asset_file_path)}"
      end

      should "log missing media file path" do
        assert_includes @output, "Not found: media_dir/MiUser/743px-Laurentius_de_Voltolina_001.jpg"
      end
    end
  end
end
