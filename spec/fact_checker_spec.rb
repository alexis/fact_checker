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

    specify 'FactTest.def_fact' do
      FactTest.should respond_to :def_fact

      class FactTest
        def_fact :fact_test1
      end

      FactTest.fact_checker.facts.should == [:fact_test1]
    end

    describe 'instance of FactTest' do
      let(:fact_test) { FactTest.new }

      specify '#fact_accomplished?' do
        fact_test.should respond_to :fact_accomplished?
      end

      specify '#fact_possible?' do
        fact_test.should respond_to :fact_possible?
      end

      specify '#facts' do
        fact_test.should respond_to :facts
        fact_test.facts.should == [:fact_test1]
      end

      specify '#accomplished_facts' do
        fact_test.should respond_to :accomplished_facts
      end

      specify '#possible_facts' do
        fact_test.should respond_to :possible_facts
      end
    end
  end
end
