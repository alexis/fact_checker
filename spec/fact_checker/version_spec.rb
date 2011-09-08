#!/usr/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe 'FactChecker::VERSION' do
  subject { FactChecker::VERSION }

  it { should =~ /\A\d+\.\d+\.\d+\z/ }
end
