# encoding: utf-8

require "forwardable"
require "fact_checker/version"
require "fact_checker/base"

module FactChecker
  def self.included(base)
    base.extend ClassMethods
    base.extend Forwardable

    base.class_eval {
      def_delegators :'self.class.fact_checker', :facts, :accomplished_facts, :possible_facts
    }
  end

  module ClassMethods
    def def_fact(*options)
      fact_checker.def_fact(*options)
    end

    def fact_checker
      @fact_checker ||= FactChecker::Base.new
    end
  end

  def fact_accomplished?(fact)
    self.class.fact_checker.fact_accomplished?(self, fact)
  end

  def fact_possible?(fact)
    self.class.fact_checker.fact_possible?(self, fact)
  end
end
