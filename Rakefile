require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

#############################################################################
#
# Test tasks
#
#############################################################################

namespace :migrate do
  desc "Migrate from mephisto in the current directory"
  task :mephisto do
    sh %q(ruby -r './lib/jekyll/migrators/mephisto' -e 'Jekyll::Mephisto.postgres(:database => "#{ENV["DB"]}")')
  end
  desc "Migrate from Movable Type in the current directory"
  task :mt do
    sh %q(ruby -r './lib/jekyll/migrators/mt' -e 'Jekyll::MT.process("#{ENV["DB"]}", "#{ENV["USER"]}", "#{ENV["PASS"]}")')
  end
  desc "Migrate from Typo in the current directory"
  task :typo do
    sh %q(ruby -r './lib/jekyll/migrators/typo' -e 'Jekyll::Typo.process("#{ENV["DB"]}", "#{ENV["USER"]}", "#{ENV["PASS"]}")')
  end
end
