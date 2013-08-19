# Fact Checker [![Build Status](https://secure.travis-ci.org/alexis/fact_checker.png?branch=master)](http://travis-ci.org/alexis/fact_checker)
[![Code Climate](https://codeclimate.com/github/ipoval/fact_checker.png)](https://codeclimate.com/github/ipoval/fact_checker)

  Simple ruby gem to check hierarchically dependent "facts" about objects.

## Installation

    gem install fact_checker

## Synopsys

``` ruby
class Person
  include FactChecker

  def_fact :rich,        if: :big_paycheck
  def_fact :good_job,    if: ->(p) { p.job.good? }
  def_fact :good_family, if: ->(p) { p.family.good? }
  # or
  def_fact :is_healthy,  if: -> { health.good? }
  def_fact :is_happy => [:is_healthy, :good_family, :good_job],  if: ->(p) { ! p.too_clever? }

  ...
end

p = Person.new(job: good_job, family: good_family, health: :good, intellect: :too_clever)
p.fact_accomplished?(:good_job) # => true
p.good_family?                  # => true
p.is_healthy?                   # => true
p.fact_possible?(:is_happy)     # => true (dependency satisfied)
p.is_happy?                     # => false

p.possible_facts - p.accomplished_facts # => [:happy]
```
