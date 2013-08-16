# encoding: utf-8

require 'spec_helper'

describe FactChecker do
  describe ClassWithNoFacts do
    subject { ClassWithNoFacts.new }

    its(:facts)              { should == [] }
    its(:possible_facts)     { should == [] }
    its(:accomplished_facts) { should == [] }

    specify '#fact_possible? and #fact_accomplished?' do
      subject.fact_possible?(:unknown_fact).should be_true
      subject.fact_accomplished?(:unknown_fact).should be_false
    end
  end

  describe ClassWithFacts do
    subject { ClassWithFacts }

    it { should respond_to :def_fact }
    its(:fact_checker) { should be_kind_of FactChecker::Definition }

    context 'instance methods' do
      let(:target) { ClassWithFacts.new }

      context 'given private fact', fact: :_private_fact do
        specify 'private fact included in #facts' do
          target.facts.should include example.metadata[:fact]
        end

        specify 'private fact does not have a predicate method' do
          target.methods(true).should_not include example.metadata[:fact]
          -> { target.send(example.metadata[:fact].to_s + '?') }.should raise_error NoMethodError
        end
      end

      context 'given bare fact', fact: :bare_fact do
        it_behaves_like 'an accomplished fact', true
        it_behaves_like 'a possible fact',      true
      end

      context 'given true fact with no dependencies', fact: :true_fact_with_no_dependencies  do
        it_behaves_like 'an accomplished fact', true
        it_behaves_like 'a possible fact',      true
      end

      context 'given true fact with true dependencies', fact: :true_fact_with_true_dependencies do
        it_behaves_like 'an accomplished fact', true
        it_behaves_like 'a possible fact',      true
      end

      context 'given true fact with false dependencies', fact: :true_fact_with_false_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      false
      end

      context 'given false fact with no dependencies', fact: :false_fact_with_no_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      true
      end

      context 'given false fact with true dependencies', fact: :false_fact_with_true_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      true
      end

      context 'given false fact with false dependencies', fact: :false_fact_with_false_dependencies do
        it_behaves_like 'an accomplished fact', false
        it_behaves_like 'a possible fact',      false
      end

      specify '#facts' do
        target.facts.size.should be 8
      end

      specify '#accomplished_facts' do
        target.accomplished_facts.should == [:bare_fact, :true_fact_with_no_dependencies, :true_fact_with_true_dependencies, :_private_fact]
      end

      specify '#possible_facts' do
        target.possible_facts.should == target.facts - [:true_fact_with_false_dependencies, :false_fact_with_false_dependencies]
      end

      specify 'symbolic and string facts are the same thing' do
        target.class.class_eval { def_fact(:symbolic_fact) { false } }
        target.symbolic_fact?.should be false
        target.fact_accomplished?(:symbolic_fact).should be false
        target.fact_accomplished?('symbolic_fact').should be false
        target.fact_possible?(:symbolic_fact).should be true
        target.fact_possible?('symbolic_fact').should be true

        target.class.class_eval { def_fact('symbolic_fact') { true } }
        target.symbolic_fact?.should be true
        target.fact_accomplished?(:symbolic_fact).should be true
        target.fact_accomplished?('symbolic_fact').should be true
        target.fact_possible?(:symbolic_fact).should be true
        target.fact_possible?('symbolic_fact').should be true

        target.facts.count(:symbolic_fact).should be 1
        target.facts.size.should be 9
      end

    end
  end
end
