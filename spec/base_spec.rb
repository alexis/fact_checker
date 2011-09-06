require 'fact_checker'

describe FactChecker::Base do
  describe "constructor" do
    it "should accept facts, deppendencies and requirements as arguments" do
      fc = FactChecker::Base.new([:a, :b], {:a => :b}, {:b => :nil?})
      fc.facts.should          == [:a, :b]
      fc.deppendencies.should  == {:a => :b}
      fc.requirements.should   == {:b => :nil?}
    end
    it "should use empty hash as a default for requirements" do
      fc = FactChecker::Base.new([:a, :b], {:a => :b})
      fc.requirements.should == {}
    end
    it "should use empty hash as a default for deppendencies" do
      fc = FactChecker::Base.new([:a, :b])
      fc.deppendencies.should == {}
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
    it "should raise FactChecker::Error if requirement has wrong type" do
      fc = FactChecker::Base.new([:f1], nil, {:f1 => "wrong"})
      lambda{fc.requirement_satisfied_for?(nil, :f1)}.should raise_error(FactChecker::Error)
    end

    describe "#fact_acomplished?" do
      it "should return false if fact is unknown" do
        fc = FactChecker::Base.new([:f2], nil, {:f1 => :nil?})
        fc.fact_accomplished?(nil, :f1).should be_false
      end
      it "should return true if requirement satisfied and fact has no deppendencies" do
        fc = FactChecker::Base.new([:f1], nil, {:f1 => lambda{|o| o.size > 2}})
        fc.fact_accomplished?("name", :f1).should be_true
      end
      it "should return false if requirement not satisfied (fact has no deppendencies)" do
        fc = FactChecker::Base.new([:f1], nil, {:f1 => :nil?})
        fc.fact_accomplished?("something", :f1).should be_false
      end
      it "should return false if fact has unsatisfied deppendencies" do
        fc = FactChecker::Base.new([:f1, :f2], {:f1 => :f2}, {:f2 => :nil?})
        fc.fact_accomplished?("something", :f1).should be_false
      end
      it "should return false if fact has both satisfied and unsatisfied deppendencies" do
        fc = FactChecker::Base.new([:f1, :f2, :f3, :f4], {:f1 => [:f2, :f3], :f3 => :f4}, {:f2 => :size, :f3 => :size, :f4 => :nil?})
        fc.fact_accomplished?("something", :f1).should be_false
      end
      it "should return true if all requirements are satisfied and fact has no requirements" do
        fc = FactChecker::Base.new([:f1, :f2, :f3, :f4], {:f1 => [:f2, :f3], :f3 => :f4}, {:f2 => :size, :f3 => :size, :f4 => :size})
        fc.fact_accomplished?("something", :f1).should be_true
      end
      it "should return false if requirements not satisfied (all deppendencies are satisfied)" do
        fc = FactChecker::Base.new([:f1, :f2, :f3, :f4], {:f1 => [:f2, :f3], :f3 => :f4}, {:f1 => :nil?, :f2 => :size, :f3 => :size, :f4 => :size})
        fc.fact_accomplished?("something", :f1).should be_false
      end
    end

    describe "#fact_possible?" do
      it "should return true if fact is unknown" do
        fc = FactChecker::Base.new([:f2], nil, {:f1 => :nil?})
        fc.fact_possible?(nil, :f1).should be_true
      end
      it "should return true if deppendencies satisfied (even if requirement is not satisfied)" do
        fc = FactChecker::Base.new([:f1], nil, {:f1 => :nil?})
        fc.fact_possible?(1, :f1).should be_true
      end
      it "should return false if deppendencies unsatisfied (even if requirement is satisfied)" do
        fc = FactChecker::Base.new([:f1], {:f1 => :f2}, {:f2 => :nil?})
        fc.fact_possible?(1, :f1).should be_false
      end
    end
  end
end
