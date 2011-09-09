#!/usr/bin/env ruby
# encoding: utf-8

require "fact_checker/version"
require "fact_checker/base"

module FactChecker
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def define_fact(*options)
      fact_checker.define_fact options
    end

    def fact_checker
      @fact_checker ||= FactChecker::Base.new
    end
  end

  [ :fact_on?, :fact_can?, :facts, :facts_on, :facts_can ].each do |m|
    define_method(m) { |fact| self.class.fact_checker.send(m, self, fact) }
  end
end
