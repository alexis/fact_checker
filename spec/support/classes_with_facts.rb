# encoding: utf-8

require 'spec_helper'

class ClassWithNoFacts
  include FactChecker
end

class ClassWithFacts
  include FactChecker

  def_fact :bare_fact
  def_fact :true_fact_with_no_dependencies, :if => lambda { is_ruby_awesome? }
  def_fact 'true_fact_with_true_dependencies' => :bare_fact, :if => lambda { true }
  def_fact :true_fact_with_false_dependencies => :false_fact_with_no_dependencies, :if => lambda { true }
  def_fact :false_fact_with_no_dependencies, :if => lambda { false }
  def_fact 'false_fact_with_true_dependencies' => :bare_fact , :if => lambda { false }
  def_fact :false_fact_with_false_dependencies => :false_fact_with_no_dependencies , :if => lambda { false }

  def_fact :_private_fact

  def is_ruby_awesome?; true; end
  private :is_ruby_awesome?
end

class ChildOfClassWithFacts < ClassWithFacts
end

# :another_fact should not creep back to parent classes
class GrandChildOfClassWithFacts < ChildOfClassWithFacts
  def_fact :another_fact
end
