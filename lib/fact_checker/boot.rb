# encoding: utf-8

module FactChecker
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def inherited(child)
      child.instance_variable_set('@fact_checker', fact_checker.dup)
    end

    def def_fact(*opts)
      symbolic_fact_name = fact_checker.def_fact(*opts)
      fact_name = symbolic_fact_name.to_s + '?'
      unless fact_name.start_with? '_'
        define_method(fact_name) { fact_accomplished?(symbolic_fact_name) }
      end
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
