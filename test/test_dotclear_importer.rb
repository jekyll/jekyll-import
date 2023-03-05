# frozen_string_literal: true

require "helper"
require "tempfile"

Importers::Dotclear.require_deps

# Monkey-patch `Jekyll.logger.abort_with()` to not abort tests.
module Jekyll
  class LogAdapter
    def abort_with(topic, message = nil, &block)
      error(topic, message, &block)
    end
  end
end

class TestDotclearImporter < Test::Unit::TestCase
  def described_class
    Importers::Dotclear
  end

  context "Invalid export file" do
    should "log graceful error message" do
      Tempfile.open("bad-export.txt") do |file|
        file << "Lorem ipsum dolor sit"
        file.rewind

        output = capture_output { described_class.validate("datafile" => file.path) }
        error_msg = "#{file.path.inspect} is not a valid Dotclear export file!"

        assert_includes output, error_msg
      end 
    end
  end

  context "Importing with valid export file" do
    setup do
      orig_pwd = Dir.pwd
      @export_file = File.join(orig_pwd, "test/mocks/dotclear.txt")

      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          @output = capture_output { described_class.run("datafile" => @export_file) }
          @post_path = "_drafts/2017-03-25-welcome-to-dotclear.md"
          @contents = File.read(@post_path)
        end
      end
    end

    should "log export file path" do
      assert_includes @output, "Export File: #{@export_file}"
    end

    should "create post files with front matter and Markdown content" do
      assert_includes @output, "Creating: #{@post_path}"
      assert_includes @contents, "---\nlayout: post\ntitle: Welcome to Dotclear!\n"
      assert_includes @contents, "tags:\n- Indiana\n"
      assert_includes @contents, "---\n\nThis is your first entry."
    end
  end
end
