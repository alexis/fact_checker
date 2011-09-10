# encoding: utf-8

require "fact_checker/base"
require "fact_checker/version"

module FactChecker
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def def_fact(*options)
      fact_checker.def_fact(*options)
    end

    def fact_checker
      @fact_checker ||= FactChecker::Base.new
    end
  end

  [:fact_accomplished?, :fact_possible?, :accomplished_facts, :possible_facts].each do |name|
    define_method(name) { |*options| fact_checker.send(name, self, *options) }
  end
  def facts; fact_checker.facts; end

private

  def fact_checker
    self.class.fact_checker
  end
end
