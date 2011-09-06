# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fact_checker/version"

Gem::Specification.new do |s|
  s.name        = "fact_checker"
  s.version     = FactChecker::VERSION
  s.authors     = ["Alexey Smolianinov"]
  s.email       = ["alexisowl+fact_checker@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Checks facts which may deppend on other facts}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "fact_checker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec", '~> 2'
  # s.add_runtime_dependency "rest-client"
end
