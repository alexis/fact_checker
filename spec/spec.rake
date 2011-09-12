# encoding: utf-8

require 'rspec/core/rake_task'

desc 'Run complete application spec suite'
RSpec::Core::RakeTask.new(:spec)

spec_tasks = Dir['spec/*/'].map { |d| File.basename(d) }

spec_tasks.each do |folder|
  RSpec::Core::RakeTask.new("spec:#{folder}") do |t|
    t.pattern = "./spec/#{folder}/**/*_spec.rb"
    t.rspec_opts = %w(--color)
  end
end

# task 'spec' => spec_tasks.map { |f| "spec:#{f}" }
