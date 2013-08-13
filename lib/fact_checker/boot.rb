# encoding: utf-8

module FactChecker
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def inherited(child)
      child.instance_variable_set('@fact_checker', fact_checker.dup)
    end

    def def_fact(*opts, &block)
      fact = fact_checker.def_fact(*opts, &block)
      define_method(fact + '?') { fact_accomplished?(fact.to_s) } unless fact.is_private?
    end

    def fact_checker
      @fact_checker ||= FactChecker::Base.new
    end
  end

  # Delegate methods to self.class.fact_checker
  [:fact_accomplished?, :fact_possible?, :accomplished_facts, :possible_facts].each do |name|
    define_method(name) { |*opts| self.class.fact_checker.send(name, self, *opts) }
  end
  def facts; self.class.fact_checker.facts; end
end
