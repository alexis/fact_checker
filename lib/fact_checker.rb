# encoding: utf-8

require "fact_checker/version"
require "fact_checker/base"

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

  def fact_accomplished?
  end

  def fact_possible?
  end
end
