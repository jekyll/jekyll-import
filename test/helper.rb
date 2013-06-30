if RUBY_VERSION > '1.9' && ENV["COVERAGE"] == "true"
  require 'simplecov'
  require 'simplecov-gem-adapter'
  SimpleCov.start('gem')
end

require 'test/unit'
require 'redgreen' if RUBY_VERSION < '1.9'
require 'shoulda'
require 'rr'

unless defined?(Test::Unit::AssertionFailedError)
  require 'activesupport'
  class Test::Unit::AssertionFailedError < ActiveSupport::TestCase::Assertion
  end
end

Dir.glob(File.expand_path('../../lib/jekyll/jekyll-import/*', __FILE__)).each do |f|
  require f
end

# Send STDERR into the void to suppress program output messages
STDERR.reopen(test(?e, '/dev/null') ? '/dev/null' : 'NUL:')

class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def dest_dir(*subdirs)
    File.join(File.dirname(__FILE__), 'dest', *subdirs)
  end

  def source_dir(*subdirs)
    File.join(File.dirname(__FILE__), 'source', *subdirs)
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
