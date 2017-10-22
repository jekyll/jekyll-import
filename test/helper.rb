if ENV["COVERAGE"] == "true"
  require "simplecov"
  require "simplecov-gem-adapter"
  SimpleCov.start("gem")
end

require "test/unit"
require "shoulda"
require "rr"

unless defined?(Test::Unit::AssertionFailedError)
  require "active_support"
  class Test::Unit::AssertionFailedError < ActiveSupport::TestCase::Assertion
  end
end

require File.expand_path("../lib/jekyll-import.rb", __dir__)
include JekyllImport

JekyllImport::Importer.subclasses.each(&:require_deps)

# Send STDERR into the void to suppress program output messages
# STDERR.reopen(test(?e, '/dev/null') ? '/dev/null' : 'NUL:')

class Test::Unit::TestCase
  def dest_dir(*subdirs)
    File.join(__dir__, "dest", *subdirs)
  end

  def source_dir(*subdirs)
    File.join(__dir__, "source", *subdirs)
  end

  def clear_dest
    FileUtils.rm_rf(dest_dir)
  end

  def capture_stdout
    $old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.rewind
    return $stdout.string
  ensure
    $stdout = $old_stdout
  end
end
