# encoding: utf-8

require 'spec_helper'

describe 'FactCheckerInheritance' do
  describe ChildOfClassWithFacts do
    subject { ChildOfClassWithFacts }

    it { should respond_to :def_fact }
    its(:fact_checker) { should be_kind_of FactChecker::Definition }

    describe 'context for inherited facts' do
      let(:target) { ChildOfClassWithFacts.new }

      context 'inherited bare fact', fact: :bare_fact do
        it_behaves_like 'an accomplished fact', true
        it_behaves_like 'a possible fact',      true
      end

      context 'inherited true fact with no dependencies', fact: :true_fact_with_no_dependencies  do
        it_behaves_like 'an accomplished fact', true
        it_behaves_like 'a possible fact',      true
      end

      context 'inherited true fact with true dependencies', fact: :true_fact_with_true_dependencies do
        it_behaves_like 'an accomplished fact', true
        it_behaves_like 'a possible fact',      true
      end

      context 'inherited true fact with false dependencies', fact: :true_fact_with_false_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      false
      end

      context 'inherited false fact with no dependencies', fact: :false_fact_with_no_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      true
      end

      context 'inherited false fact with true dependencies', fact: :false_fact_with_true_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      true
      end

      context 'inherited false fact with false dependencies', fact: :false_fact_with_false_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      false
      end

      specify '#facts' do
        target.facts.size.should == 8
      end

      specify '#accomplished_facts' do
        target.accomplished_facts.should == [:bare_fact, :true_fact_with_no_dependencies, :true_fact_with_true_dependencies, :_private_fact]
      end

      specify '#possible_facts' do
        target.possible_facts.should == target.facts - [:true_fact_with_false_dependencies, :false_fact_with_false_dependencies]
      end
    end
  end
end
