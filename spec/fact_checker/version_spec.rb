# encoding: utf-8

require 'spec_helper'

describe FactChecker::VERSION do
  it { should =~ /\A\d+\.\d+\.\d+\z/ }
end
