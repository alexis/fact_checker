# Fact Checker

  Simple ruby gem to check hierarchically dependent "facts" about objects.

## Installation

    gem install fact_checker

## Synopsys

``` ruby
class Person
  include FactChecker

  def_fact :good_job,      :if => lambda { |p| p.job.good? }
  def_fact :good_family,   :if => lambda { |p| p.family.good? }
  def_fact :is_healthy,    :if => lambda { |p| p.health.good? }
  def_fact :is_happy => [:is_healthy, :good_family, :good_job],  :if => lambda { |p| ! p.too_clever? }

  ...
end

p = Person.new(:job => good_job, :family => good_family, :health => :good, :intellect => :too_clever)
p.has_good_job? # => true
p.has_good_family? # => true
p.is_healthy? # => true
p.fact_possible?(:is_happy) # => true    (dependency satisfied)
p.is_happy? # => false

p.possible_facts - p.accomplished_facts # => [:happy]
```
