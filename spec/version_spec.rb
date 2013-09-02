# encoding: utf-8

require 'spec_helper'

describe 'FactChecker::VERSION' do
  it "is valid" do
    expect(FactChecker::VERSION).to match(/\A\d+\.\d+\.\d+\Z/)
  end
end
