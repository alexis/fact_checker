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

    specify 'FactTest.fact_checker' do
      FactTest.should respond_to :fact_checker
      FactTest.fact_checker.should be_kind_of FactChecker::Base
    end

    specify 'FactTest.define_fact' do
      FactTest.should respond_to :define_fact
    end

    describe 'instance of FactTest' do
      let(:fact_test) { FactTest.new }

      specify '#fact_on?' do
        fact_test.should respond_to :fact_on?
      end

      specify '#fact_can?' do
        fact_test.should respond_to :fact_can?
      end

      specify '#facts' do
        fact_test.should respond_to :facts
      end

      specify '#facts_on' do
        fact_test.should respond_to :facts_on
      end

      specify '#facts_can' do
        fact_test.should respond_to :facts_can
      end
    end
  end
end
