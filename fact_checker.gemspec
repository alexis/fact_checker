# encoding: utf-8

$:.push File.expand_path("../lib", __FILE__)
require "fact_checker/version"

Gem::Specification.new do |s|
  s.name        = "fact_checker"
  s.version     = FactChecker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alexey Smolianinov"]
  s.email       = ["alexisowl+fact_checker@gmail.com"]
  s.homepage    = "https://github.com/alexis/fact_checker"
  s.summary     = %q{Checks facts which may depend on other facts}
  s.description = %q{Simple gem to check hierarchically dependent "facts" about objects}

  s.rubyforge_project = "fact_checker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.5"

  {
    'bundler' => '~> 1.0.18',
    'rake'    => '~> 0.9.2',
    'rspec'   => '~> 2.6',
  }.each do |lib, version|
    s.add_development_dependency lib, version
  end
end
