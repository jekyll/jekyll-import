Gem::Specification.new do |s|
  s.name              = 'jekyll-import'
  s.version           = '0.12.0'
  s.license           = 'MIT'
  s.date              = '2012-12-22'
  
  s.summary     = "A simple, blog aware, static site generator."
  s.description = "Jekyll is a simple, blog aware, static site generator."
  
  s.authors  = ["Tom Preston-Werner"]
  s.email    = 'tom@mojombo.com'
  s.homepage = 'http://github.com/jekyll/jekyll-import'
  
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = %w[lib]
  
  s.add_runtime_dependency('safe_yaml', "~> 0.4")
  
  s.add_development_dependency('rake', "~> 10.0.3")
  
  # test dependencies:
  s.add_development_dependency('redgreen', "~> 1.2")
  s.add_development_dependency('shoulda', "~> 3.3.2")
  s.add_development_dependency('rr', "~> 1.0")
  s.add_development_dependency('simplecov', "~> 0.7")
  s.add_development_dependency('simplecov-gem-adapter', "~> 1.0.1")

  # migrator dependencies:
  s.add_development_dependency('sequel', "~> 3.42")
  s.add_development_dependency('htmlentities', "~> 4.3")
  s.add_development_dependency('hpricot', "~> 0.8")
  
end
