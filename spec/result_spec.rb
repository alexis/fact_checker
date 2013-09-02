# encoding: utf-8

require 'spec_helper'

describe FactChecker::Result do
  context "initialized with (dependency_result, requirement_result)" do

    context "when dependency_result = true" do
      context "when requirement_result = true" do
        subject { described_class.new(true, true) }
        its(:valid?) { should == true }
        its(:available?) { should == true }
      end

      context "when requirement_result = false" do
        subject { described_class.new(true, false) }
        its(:valid?) { should == false }
        its(:available?) { should == true }
      end
    end

    context "when dependency_result = false" do
      subject { described_class.new(false, true) }
      its(:valid?) { should == false }
      its(:available?) { should == false }
    end

  end
end
