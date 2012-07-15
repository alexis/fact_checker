# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)
require "fact_checker/version"

Gem::Specification.new do |s|
  s.name        = "fact_checker"
  s.version     = FactChecker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alexey Smolianinov", "Ivan Povalyukhin"]
  s.email       = ["alexisowl+fact_checker@gmail.com"]
  s.homepage    = "https://github.com/alexis/fact_checker"
  s.summary     = %q{Checks facts which may depend on other facts}
  s.description = %q{Simple gem to check hierarchically dependent "facts" about objects}

  s.rubyforge_project = "fact_checker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version     = '>= 1.9.2'
  s.required_rubygems_version = '>= 1.3.5'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec',     '~> 2.11.0'
  s.add_development_dependency 'debugger',  '~> 1.1.4'
  s.add_development_dependency 'simplecov', '~> 0.6.4'
end
