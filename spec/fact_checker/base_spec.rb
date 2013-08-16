# encoding: utf-8

require 'spec_helper'

describe FactChecker::Base2 do

  let(:true_block)     { proc{ !!object_id } }
  let(:false_block)    { proc{ nil? } }
  let(:validity_block) { proc{ valid? } }

  describe "#initialize" do
    context "called with all arguments (fact_list, dependencies_hash, requirements_hash), its " do
      subject { FactChecker::Base2.new([:f1, :f2], {:f1 => :f2}, {:f1 => false_block}) }
      specify("facts == fact_list") { subject.facts.should == [:f1, :f2] }
      specify("dependencies == dependencies_hash") { subject.dependencies.should == {:f1 => :f2} }
      specify("requirements == requirements_hash") { subject.requirements.should == {:f1 => false_block} }
    end

    context "called" do
      specify("without fact_list, its facts == [] by default") { subject.facts.should == [] }
      specify("without dependencies_hash, its dependencies == {} by default") { subject.dependencies.should == {} }
      specify("without requirements_hash, its requirements == {} by default") { subject.requirements.should == {} }
    end
  end

  describe "#requirement_satisfied_for?(fact)" do
    subject { FactChecker::Base2.new([:f1]) }

    context "when no requirement defined for the fact" do
      it "returns true" do
        subject.requirement_satisfied_for?(:f1).should be_true
      end
    end

    context "when requirement defined as Proc" do
      it "returns false if requirement evaluates to false" do
        subject.requirements[:f1] = false_block
        subject.requirement_satisfied_for?(:f1).should be_false
      end

      it "returns false if requirement evaluates to true" do
        subject.requirements[:f1] = true_block
        subject.requirement_satisfied_for?(:f1).should be_true
      end
    end

    context "when requirement was defined as something else" do
      it "raises RuntimeError" do
        subject.requirements[:f1] = :something_else
        lambda{ subject.requirement_satisfied_for?(:f1) }.should raise_error(RuntimeError)
      end
    end
  end

  describe "#fact_accomplished?" do
    context "when fact is unknown" do
      subject { FactChecker::Base2.new([:f2], nil, {:f1 => true_block}) }
      it("always returns false") { subject.fact_accomplished?(:f1).should be_false }
    end

    context "when fact is known and" do
      context "has no dependencies" do
        subject { FactChecker::Base2.new([:f1], nil, {:f1 => validity_block}) }

        it("returns true if requirement satisfied") do
          allow(subject).to receive(:valid?) { true }
          subject.fact_accomplished?(:f1).should be_true
        end

        it "returns false if requirement not satisfied" do
          allow(subject).to receive(:valid?) { false }
          subject.fact_accomplished?(:f1).should be_false
        end
      end

      context "has only unsatisfied dependencies" do
        subject { FactChecker::Base2.new([:f1, :f2], {:f1 => :f2}, {:f1 => true_block, :f2 => false_block}) }

        it "returns false" do
          subject.fact_accomplished?(:f1).should be_false
        end
      end

      context "has both satisfied and unsatisfied dependencies" do
        subject {
          FactChecker::Base2.new(
            [:f1, :f2, :f3, :f4],
            {:f1 => [:f2, :f3], :f3 => :f4},
            {:f2 => true_block, :f3 => true_block, :f4 => false_block}
          )
        }

        it "returns false" do
          subject.fact_accomplished?(:f1).should be_false
        end
      end

      context "has only satisfied dependencies" do
        subject {
          FactChecker::Base2.new(
            [:f1, :f2, :f3, :f4],
            {:f1 => [:f2, :f3], :f3 => :f4},
            {:f1 => validity_block, :f2 => true_block, :f3 => true_block }
          )
        }

        it "returns true if requirement satisfied" do
          allow(subject).to receive(:valid?) { true }
          subject.fact_accomplished?(:f1).should be_true
        end

        it "returns false if requirement not satisfied" do
          allow(subject).to receive(:valid?) { false }
          subject.fact_accomplished?(:f1).should be_false
        end
      end
    end
  end

  describe "#fact_possible?" do
    context "when fact is unknown" do
      it "returns true" do
        subject.fact_possible?(:x).should be_true
      end
    end

    context "when fact is known" do
      it "returns true if dependencies satisfied (even if requirement is not satisfied)" do
        subject = FactChecker::Base2.new([:f1, :f2], {:f1 => :f2}, {:f1 => false_block, :f2 => true_block})
        subject.fact_possible?(:f1).should be_true
      end

      it "returns false if dependencies unsatisfied (even if requirement is satisfied)" do
        subject = FactChecker::Base2.new([:f1, :f2], {:f1 => :f2}, {:f1 => true_block, :f2 => false_block})
        subject.fact_possible?(:f1).should be_false
      end
    end
  end

  describe "#def_fact" do
    context "called with (:fact_name)" do
      it "adds :fact_name to facts" do
        subject.def_fact(:f1)
        subject.def_fact(:f2)
        subject.facts.should == [:f1, :f2]
      end

      it "returns :fact_name" do
        subject.def_fact(:f1).should == :f1
      end
    end

    context "called with (:fact_name) {...}" do
      it "adds :fact_name to facts" do
        subject.def_fact(:f1)
        subject.def_fact(:f2) {}
        subject.facts.should == [:f1, :f2]
      end

      it "adds block to requirements" do
        subject.def_fact(:f2) { 'foo' }
        subject.requirements[:f2].call.should == 'foo'
      end
    end

    context "called with (:fact_name => :dependency)" do
      it "adds :fact_name to facts" do
        subject.def_fact(:f1)
        subject.def_fact(:f2 => :f1)
        subject.facts.should == [:f1, :f2]
      end

      it "adds :dependency to dependencies" do
        subject.def_fact(:f2 => :f1)
        subject.dependencies[:f2].should == :f1
      end
    end

    context "called with (:fact_name => :dependency) {...}" do
      subject do
        FactChecker::Base2.new.tap do |checker|
          checker.def_fact(:f1)
          checker.def_fact(:f2 => :f1) { 'bar' }
        end
      end

      it "adds :fact_name to facts" do
        subject.facts.should == [:f1, :f2]
      end

      it "adds :requirement to requirements" do
        subject.requirements[:f2].call.should == 'bar'
      end

      it "adds :dependency to dependencies" do
        subject.dependencies[:f2].should == :f1
      end
    end

    context "called again for the same fact_name" do
      subject do
        FactChecker::Base2.new.tap do |checker|
          checker.def_fact(:f1 => :f2) {}
          checker.def_fact(:f1)
        end
      end

      it "doesn't add 2nd fact_name to facts" do
        subject.facts.should == [:f1]
      end

      it "overwrites fact_name's dependency" do
        subject.dependencies[:f1].should be_nil
      end

      it "overwrites fact_name's requirement" do
        subject.requirements[:f1].should be_nil
      end
    end

    context "called with wrong arguments it RAISES ERROR, for example" do
      specify "#def_fact()" do
        expect { subject.def_fact() }.to raise_error ArgumentError
      end

      specify "#def_fact(:fact_name, {:if => :requirement})" do
        expect { subject.def_fact(:f1, :if => lambda{}) }.to raise_error ArgumentError
      end

      specify "#def_fact(:fact_name, something_else)" do
        expect { subject.def_fact(:f1, 1) }.to raise_error ArgumentError
      end
    end
  end

  describe "3 *_facts methods, i.e." do
    subject { FactChecker::Base2.new([:f1, :f2, :f3], {:f1 => :f2}, {:f1 => true_block, :f2 => false_block }) }

    describe "#accomplished_facts" do
      it "returns accomplished facts - ones with both dependencies and requirements satisfied" do
        subject.accomplished_facts.should == [:f3]
      end
    end

    describe "#possible_facts" do
      it "returns possible facts - ones with dependencies but not necessarily requirements satisfied" do
        subject.possible_facts.should == [:f2, :f3]
      end
    end

    describe "#facts" do
      it("returns all defined facts") { subject.facts.should == [:f1, :f2, :f3] }
    end
  end

end
