#!/usr/bin/env ruby
# encoding: utf-8

Dir['./spec/support/**/*.rb'].each { |f| require f }
$:.unshift File.expand_path('../lib', __FILE__)
require 'fact_checker'

RSpec.configure do |conf|
  conf.color_enabled = true
  conf.treat_symbols_as_metadata_keys_with_true_values = true
  
  conf.expect_with :rspec, :stdlib
  conf.mock_with :rspec

  conf.fail_fast = true
  conf.filter_run :focus  => true
  conf.filter_run_excluding :broken => true
  conf.run_all_when_everything_filtered = true
end
