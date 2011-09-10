# encoding: utf-8

require 'spec_helper'

describe 'FactChecker' do
  context 'included into FactTest' do
    before :all do
      class FactTest
        include FactChecker

        def_fact :bare_fact
        def_fact :true_fact_with_no_dependencies, :if => lambda { true }
        def_fact :false_fact_with_no_dependencies, :if => lambda { false }
        def_fact :true_fact_with_true_dependencies => :bare_fact, :if => lambda { true }
        def_fact :true_fact_with_false_dependencies => :false_fact_with_no_dependencies, :if => lambda { true }
        def_fact :false_fact_with_true_dependencies => :bare_fact , :if => lambda { false }
        def_fact :false_fact_with_false_dependencies => :false_fact_with_no_dependencies , :if => lambda { false }
      end
    end

    specify 'FactTest' do
      FactTest.should respond_to :def_fact
      FactTest.fact_checker.should be_kind_of FactChecker::Base
    end

    describe 'instance of FactTest' do
      let(:fact_test) { FactTest.new }

      context 'given true fact with no dependencies' do
        specify '#fact_accomplished? returns true' do
          fact_test.fact_accomplished?(:bare_fact).should be_true
        end

        specify '#fact_possible? returns true' do
          fact_test.fact_possible?(:bare_fact).should be_true
        end
      end

      context 'given true fact with no dependencies' do
        specify '#fact_accomplished? returns true' do
          fact_test.fact_accomplished?(:true_fact_with_no_dependencies).should be_true
        end

        specify '#fact_possible? returns true' do
          fact_test.fact_possible?(:true_fact_with_no_dependencies).should be_true
        end
      end

      specify '#facts' do
        fact_test.facts.size.should == 7
      end

      specify '#accomplished_facts' do
        fact_test.accomplished_facts.should == [ :bare_fact, :true_fact_with_no_dependencies, :true_fact_with_true_dependencies ]
      end

      specify '#possible_facts' do
        fact_test.possible_facts.should == fact_test.facts - [ :true_fact_with_false_dependencies, :false_fact_with_false_dependencies ]
      end
    end
  end
end
