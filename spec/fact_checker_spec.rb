# encoding: utf-8

require 'spec_helper'

describe 'FactChecker' do
  context 'included into FactTest' do
    before :all do
      class FactTest
        include FactChecker

        def_fact :fact_with_no_dependencies_no_context
        def_fact :fact_with_true_context_no_dependencies, :if => lambda { |o| !!o.object_id }
      end
    end

    specify 'FactTest' do
      FactTest.should respond_to :def_fact
      FactTest.fact_checker.should be_kind_of FactChecker::Base
    end

    describe 'instance of FactTest' do
      let(:fact_test) { FactTest.new }

      context 'given fact with no dependencies and no context' do
        specify '#fact_accomplished? returns true' do
          fact_test.fact_accomplished?(:fact_with_no_dependencies_no_context).should be_true
        end

        specify '#fact_possible? returns true' do
          fact_test.fact_possible?(:fact_with_no_dependencies_no_context).should be_true
        end
      end

      context 'given fact with true context and no dependencies' do
        specify '#fact_accomplished? returns true' do
          fact_test.fact_accomplished?(:fact_with_true_context_no_dependencies).should be_true
        end

        specify '#fact_possible? returns true' do
          fact_test.fact_possible?(:fact_with_true_context_no_dependencies).should be_true
        end
      end

      specify '#facts' do
        fact_test.facts.should == [ :fact_with_no_dependencies_no_context,
                                    :fact_with_true_context_no_dependencies ]
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
