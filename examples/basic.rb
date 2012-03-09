# encoding: utf-8

require 'fact_checker'

class BasicExample
  include FactChecker

  def_fact :be
  def_fact :be_or => :be
  def_fact :be_or_not => :be, :if => :my_requirement?
  def_fact :be_or_not_to => [:be, :be_or_not], :if => :my_requirement?
  def_fact :be_or_not_to_be => :be, :if => lambda { |context| !context.my_requirement? }
end

target = BasicExample.new

def target.my_requirement?; false; end

p target.fact_possible?     :be
# => true
p target.fact_accomplished? :be
# => true
p target.be?
# => true

puts

p target.fact_possible?     :be_or
# => true
p target.fact_accomplished? :be_or
# => true
p target.be_or?
# => true

puts

p target.fact_possible?     :be_or_not
# => true
p target.fact_accomplished? :be_or_not
# => false
p target.be_or_not?
# => false

puts

p target.fact_possible?     :be_or_not_to
# => false
p target.fact_accomplished? :be_or_not_to
# => false
p target.be_or_not_to?
# => false

puts

p target.fact_possible?     :be_or_not_to_be
# => true
p target.fact_accomplished? :be_or_not_to_be
# => true
p target.be_or_not_to_be?
# => true
