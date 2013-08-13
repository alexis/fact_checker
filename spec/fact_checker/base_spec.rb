# encoding: utf-8

require 'spec_helper'

describe FactChecker::Base do

  describe "#initialize" do
    context "called with all arguments (fact_list, dependencies_hash, requirements_hash), its " do
      subject { FactChecker::Base.new([:f1, :f2], {:f1 => :f2}, {:f1 => :nil?}) }
      specify("facts == fact_list") { subject.facts.should == [:f1, :f2] }
      specify("dependencies == dependencies_hash") { subject.dependencies.should == {:f1 => :f2} }
      specify("requirements == requirements_hash") { subject.requirements.should == {:f1 => :nil?} }
    end

    context "called" do
      specify("without fact_list, its facts == [] by default") { subject.facts.should == [] }
      specify("without dependencies_hash, its dependencies == {} by default") { subject.dependencies.should == {} }
      specify("without requirements_hash, its requirements == {} by default") { subject.requirements.should == {} }
    end
  end

  describe "#requirement_satisfied_for?(context, fact)" do
    context "when no requirement defined for the fact" do
      subject { FactChecker::Base.new([:f1]) }
      it "returns true for any object" do
        subject.requirement_satisfied_for?(1, :f1).should be_true
        subject.requirement_satisfied_for?(nil, :f1).should be_true
      end
    end

    context "when requirement for the fact was defined as symbol" do
      subject { FactChecker::Base.new([:f1], nil, {:f1 => :nil?}) }
      it "returns false if fact is unknown" do
        subject.requirement_satisfied_for?(1, :f2).should be_false
      end
      it "returns false if context.symbol() == false" do
        subject.requirement_satisfied_for?(1, :f1).should be_false
      end
      it "returns true if context.symbol() == true" do
        subject.requirement_satisfied_for?(nil, :f1).should be_true
      end
    end

    context "when requirement was defined as Proc with arity == 1" do
      subject { FactChecker::Base.new([:f1], nil, {:f1 => lambda{|t| t.nil?}}) }
      it "returns false if proc(context) == false" do
        subject.requirement_satisfied_for?(1, :f1).should be_false
      end
      it "returns true if proc(context) == true" do
        subject.requirement_satisfied_for?(nil, :f1).should be_true
      end
    end

    context "when requirement was defined as Proc with arity == 0" do
      it "returns false if proc() == false" do
        subject = FactChecker::Base.new([:f1], nil, {:f1 => lambda{false}})
        subject.requirement_satisfied_for?(nil, :f1).should be_false
      end
      it "returns true if proc() == true" do
        subject = FactChecker::Base.new([:f1], nil, {:f1 => lambda{true}})
        subject.requirement_satisfied_for?(nil, :f1).should be_true
      end
    end

    context "when requirement was defined as something else" do
      subject { FactChecker::Base.new([:f1], nil, {:f1 => "wrong"}) }
      it "raises RuntimeError" do
        lambda{ subject.requirement_satisfied_for?(nil, :f1) }.should raise_error(RuntimeError)
      end
    end
  end

  describe "#fact_accomplished?" do
    context "when fact is unknown" do
      subject { FactChecker::Base.new([:f2], nil, {:f1 => :nil?}) }
      it("always returns false") { subject.fact_accomplished?(nil, :f1).should be_false }
    end

    context "when fact is known and" do
      context "has no dependencies" do
        subject { FactChecker::Base.new([:f1], nil, {:f1 => lambda{|o| o.size > 3}}) }
        it("returns true if requirement satisfied") do
          subject.fact_accomplished?("String", :f1).should be_true
        end
        it "returns false if requirement not satisfied" do
          subject.fact_accomplished?("Str", :f1).should be_false
        end
      end

      context "has only unsatisfied dependencies" do
        subject { FactChecker::Base.new([:f1, :f2], {:f1 => :f2}, {:f1 => lambda{true}, :f2 => :nil?}) }
        it "returns false" do
          subject.fact_accomplished?("something", :f1).should be_false
        end
      end

      context "has both satisfied and unsatisfied dependencies" do
        subject { FactChecker::Base.new([:f1, :f2, :f3, :f4], {:f1 => [:f2, :f3], :f3 => :f4}, {:f2 => :size, :f3 => :size, :f4 => :nil?}) }
        it "returns false" do
          subject.fact_accomplished?("something", :f1).should be_false
        end
      end

      context "has only satisfied dependencies" do
        subject {
          FactChecker::Base.new(
            [:f1, :f2, :f3, :f4],
            {:f1 => [:f2, :f3], :f3 => :f4},
            {:f1 => lambda{|o| o.size == 4}, :f2 => lambda{|o| o.size < 5}, :f3 => lambda{|o| o.size > 2} }
          )
        }

        it "returns true if fact has no requirement" do
          subject.fact_accomplished?("something", :f4).should be_true
        end

        it "returns false if requirement not satisfied" do
          subject.fact_accomplished?("somet", :f1).should be_false
        end

        it "returns true if all requirement are satisfied" do
          subject.fact_accomplished?("some", :f1).should be_true
        end
      end
    end
  end

  describe "#fact_possible?" do
    context "when fact is unknown" do
      it "returns true" do
        subject.fact_possible?(nil, :x).should be_true
      end
    end

    context "when fact is known" do
      it "returns true if dependencies satisfied (even if requirement is not satisfied)" do
        subject = FactChecker::Base.new([:f1, :f2], {:f1 => :f2}, {:f1 => :nil?, :f2 => :to_i})
        subject.fact_possible?(1, :f1).should be_true
      end

      it "returns false if dependencies unsatisfied (even if requirement is satisfied)" do
        subject = FactChecker::Base.new([:f1, :f2], {:f1 => :f2}, {:f1 => :to_i, :f2 => :nil?})
        subject.fact_possible?(1, :f1).should be_false
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
        subject.def_fact(:f1).should == 'f1'
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
        FactChecker::Base.new.tap do |checker|
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
        FactChecker::Base.new.tap do |checker|
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

  context "has 3 *_facts methods, i.e." do
    subject { FactChecker::Base.new([:f1, :f2, :f3], {:f1 => :f2}, {:f2 => :nil?, :f3 => lambda{false} }) }

    describe "#accomplished_facts" do
      it "returns accomplished facts - ones with both dependencies and requirements satisfied" do
        subject.accomplished_facts(nil).should == [:f1, :f2]
      end
    end

    describe "#possible_facts" do
      it "returns possible facts - ones with dependencies but not requirements satisfied" do
        subject.possible_facts("SomeString").should == [:f2, :f3]
      end
    end

    describe "#facts" do
      it("returns all defined facts") { subject.facts.should == [:f1, :f2, :f3] }
    end
  end

end
