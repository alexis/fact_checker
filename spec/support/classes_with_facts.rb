# encoding: utf-8

require 'spec_helper'

class TestClassWithNoFacts
  include FactChecker
end

class TestClassWithFacts
  include FactChecker

  def_fact :bare_fact
  def_fact :true_fact_with_no_dependencies, :if => lambda { true }
  def_fact :true_fact_with_true_dependencies => :bare_fact, :if => lambda { true }
  def_fact :true_fact_with_false_dependencies => :false_fact_with_no_dependencies, :if => lambda { true }
  def_fact :false_fact_with_no_dependencies, :if => lambda { false }
  def_fact :false_fact_with_true_dependencies => :bare_fact , :if => lambda { false }
  def_fact :false_fact_with_false_dependencies => :false_fact_with_no_dependencies , :if => lambda { false }
end
