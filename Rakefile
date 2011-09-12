# encoding: utf-8

require 'rake'
require 'bundler'

Bundler::GemHelper.install_tasks

Dir['lib/tasks/**/*.rake'].
  concat(Dir['tasks/**/*.rake']).
  concat(Dir['{test,spec}/*.rake']).each { |rake| load(rake) }

task :default => :spec
task :test => :spec # for http://test.rubygems.org/
