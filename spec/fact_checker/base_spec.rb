# encoding: utf-8

require 'spec_helper'

describe FactChecker::Base do
  describe "constructor" do
    it "should accept facts, dependencies and requirements as arguments" do
      fc = FactChecker::Base.new([:a, :b], {:a => :b}, {:b => :nil?})
      fc.facts.should         == [:a, :b]
      fc.dependencies.should  == {:a => :b}
      fc.requirements.should  == {:b => :nil?}
    end
    it "should use empty hash as a default for requirements" do
      fc = FactChecker::Base.new([:a, :b], {:a => :b})
      fc.requirements.should == {}
    end
    it "should use empty hash as a default for dependencies" do
      fc = FactChecker::Base.new([:a, :b])
      fc.dependencies.should == {}
    end
    it "should use empty array as a default for facts" do
      fc = FactChecker::Base.new()
      fc.facts.should == []
    end
  end

  describe "#facts" do
    it "should return all facts" do
      fc = FactChecker::Base.new([:f1, :f2])
      fc.facts.should == [:f1, :f2]
    end
  end

  describe "#accomplished_facts" do
    it "should return accomplished facts" do
      fc = FactChecker::Base.new([:f1, :f2], nil, {:f2 => lambda{ false }})
      fc.accomplished_facts("context").should == [:f1]
    end
  end

  describe "#possible_facts" do
    it "should return possible facts" do
      fc = FactChecker::Base.new([:f1, :f2], {:f1 => :f2}, {:f2 => lambda{ false }})
      fc.possible_facts("context").should == [:f2]
    end
  end

  describe "#requirement_satisfied_for?" do
    it "should return true if no requerment defined for the step" do
      fc = FactChecker::Base.new([:f1])
      fc.requirement_satisfied_for?(1, :f1).should be_true
    end
    it "should return false if fact is unknown" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => :nil?})
      fc.requirement_satisfied_for?(1, :f2).should be_false
    end
    it "should return false if requirement is :symbol and context.symbol() == false" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => :nil?})
      fc.requirement_satisfied_for?(1, :f1).should be_false
    end
    it "should return true if requirement is :symbol and context.symbol() == true" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => :nil?})
      fc.requirement_satisfied_for?(nil, :f1).should be_true
    end
    it "should return false if requirement is Proc and proc(context) == false" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => lambda{|t| t.nil?}})
      fc.requirement_satisfied_for?(1, :f1).should be_false
    end
    it "should return true if requirement is Proc and proc(context) == true" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => lambda{|t| t.nil?}})
      fc.requirement_satisfied_for?(nil, :f1).should be_true
    end
    it "should return false if requirement is Proc with arity < 1 and proc() == false" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => lambda{false}})
      fc.requirement_satisfied_for?(nil, :f1).should be_false
    end
    it "should return true if requirement is Proc with arity < 1 and proc() == true" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => lambda{true}})
      fc.requirement_satisfied_for?(nil, :f1).should be_true
    end
    it "should raise RuntimeError if requirement has wrong type" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => "wrong"})
      lambda{fc.requirement_satisfied_for?(nil, :f1)}.should raise_error(RuntimeError)
    end
  end

  describe "#fact_accomplished?" do
    it "should return false if fact is unknown" do
      fc = FactChecker::Base.new([:f2], nil, {:f1 => :nil?})
      fc.fact_accomplished?(nil, :f1).should be_false
    end
    it "should return true if requirement satisfied and fact has no dependencies" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => lambda{|o| o.size > 2}})
      fc.fact_accomplished?("name", :f1).should be_true
    end
    it "should return false if requirement not satisfied (fact has no dependencies)" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => :nil?})
      fc.fact_accomplished?("something", :f1).should be_false
    end
    it "should return false if fact has unsatisfied dependencies" do
      fc = FactChecker::Base.new([:f1, :f2], {:f1 => :f2}, {:f2 => :nil?})
      fc.fact_accomplished?("something", :f1).should be_false
    end
    it "should return false if fact has both satisfied and unsatisfied dependencies" do
      fc = FactChecker::Base.new([:f1, :f2, :f3, :f4], {:f1 => [:f2, :f3], :f3 => :f4}, {:f2 => :size, :f3 => :size, :f4 => :nil?})
      fc.fact_accomplished?("something", :f1).should be_false
    end
    it "should return true if all requirements are satisfied and fact has no requirements" do
      fc = FactChecker::Base.new([:f1, :f2, :f3, :f4], {:f1 => [:f2, :f3], :f3 => :f4}, {:f2 => :size, :f3 => :size, :f4 => :size})
      fc.fact_accomplished?("something", :f1).should be_true
    end
    it "should return false if requirements not satisfied (all dependencies are satisfied)" do
      fc = FactChecker::Base.new([:f1, :f2, :f3, :f4], {:f1 => [:f2, :f3], :f3 => :f4}, {:f1 => :nil?, :f2 => :size, :f3 => :size, :f4 => :size})
      fc.fact_accomplished?("something", :f1).should be_false
    end
  end

  describe "#fact_possible?" do
    it "should return true if fact is unknown" do
      fc = FactChecker::Base.new([:f2], nil, {:f1 => :nil?})
      fc.fact_possible?(nil, :f1).should be_true
    end
    it "should return true if dependencies satisfied (even if requirement is not satisfied)" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => :nil?})
      fc.fact_possible?(1, :f1).should be_true
    end
    it "should return false if dependencies unsatisfied (even if requirement is satisfied)" do
      fc = FactChecker::Base.new([:f1], {:f1 => :f2}, {:f2 => :nil?})
      fc.fact_possible?(1, :f1).should be_false
    end
  end

  describe "#def_fact" do
    let(:fc) { FactChecker::Base.new }

    it "should add argument to facts when called with (:fact) and return (:fact)" do
      fc.def_fact(:f1).should be :f1
      fc.def_fact(:f2).should be :f2
      fc.facts.should == [:f1, :f2]
    end

    it "should define fact correctly when called with (:fact, :if => :requirement)" do
      fc.def_fact(:f1)
      fc.def_fact(:f2, :if => :nil?)
      fc.facts.should == [:f1, :f2]
      fc.requirements[:f2].should == :nil?
    end

    it "should define fact correctly when called with (:fact => :dependency)" do
      fc.def_fact(:f1)
      fc.def_fact(:f2 => :f1)
      fc.facts.should == [:f1, :f2]
      fc.dependencies[:f2].should == :f1
    end

    it "should define fact correctly when called with (:fact => :dependency, :if => :requirement)" do
      fc.def_fact(:f1)
      fc.def_fact(:f2 => :f1, :if => :nil?)
      fc.facts.should == [:f1, :f2]
      fc.dependencies[:f2].should == :f1
      fc.requirements[:f2].should == :nil?
    end

    it "should redefine fact if a fact with a given name already exists" do
      fc.def_fact(:f1 => :f2, :if => :nil?)
      fc.def_fact(:f1)
      fc.facts.should == [:f1]
      fc.requirements[:f1].should be_nil
      fc.dependencies[:f1].should be_nil
    end

    it "should raise ArgumentError exception when called with wrong arguments" do
      expect { fc.def_fact() }.to                                                  raise_error ArgumentError
      expect { fc.def_fact(:f1, {:if => :nil?}, true) }.to                         raise_error ArgumentError
      expect { fc.def_fact(:f1, :f2) }.to                                          raise_error ArgumentError
      expect { fc.def_fact({:if => :nil?}, :f1) }.to                               raise_error ArgumentError
      expect { fc.def_fact(:f1 => :f2, :if => :nil?, :something_else => true) }.to raise_error ArgumentError
    end
  end
end
