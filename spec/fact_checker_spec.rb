#!/usr/bin/env ruby
# encoding: utf-8

require 'spec_helper'

describe 'FactChecker' do
  context 'included into FactTest' do
    before :all do
      class FactTest
        include FactChecker
      end
    end

    specify 'FactTest has @fact_checker' do
      FactTest.instance_variables.should include '@fact_checker'
      FactTest.instance_eval { @fact_checker }.should be_kind_of FactChecker::Base
    end

    describe 'instance of FactTest' do
      let(:fact_test) { FactTest.new }

      specify '#step_accomplished?' do
        fact_test.should respond_to :step_accomplished?
      end

      specify '#step_possible?' do
        fact_test.should respond_to :step_possible?
      end

      specify '#step' do
        fact_test.should respond_to :steps
      end

      specify '#possible_steps' do
        fact_test.should respond_to :possible_steps
      end

      specify '#accomplished_steps' do
        fact_test.should respond_to :accomplished_steps
      end
    end
  end
end
