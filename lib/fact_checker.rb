# encoding: utf-8

require "fact_checker/base"
require "fact_checker/version"

module FactChecker
  def self.included(base)
    base.extend ClassMethods
    base.instance_variable_set('@fact_checker', FactChecker::Base.new)
  end

  module ClassMethods
    def inherited(child)
      child.instance_variable_set('@fact_checker', @fact_checker.dup)
    end

    def def_fact(*opts)
      fact_name = fact_checker.def_fact(*opts)
      define_method(fact_name.to_s << '?') { fact_accomplished?(fact_name) }
    end

    def fact_checker
      @fact_checker ||= FactChecker::Base.new
    end
  end

  [:fact_accomplished?, :fact_possible?, :accomplished_facts, :possible_facts].each do |name|
    define_method(name) { |*opts| fact_checker.send(name, self, *opts) }
  end
  def facts; fact_checker.facts end

private

  def fact_checker
    self.class.fact_checker
  end
end
