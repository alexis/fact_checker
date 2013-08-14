# Fact Checker [![Build Status](https://secure.travis-ci.org/alexis/fact_checker.png?branch=master)](http://travis-ci.org/alexis/fact_checker)

  Simple ruby gem to check hierarchically dependent "facts" about objects.

## Synopsys

``` ruby
class Person
  include FactChecker

  def_fact(:good_job)    { p.job.good? }
  def_fact(:good_family) { p.family.good? }
  def_fact(:is_healthy)  { p.health.good? }
  def_fact(:is_happy => [:is_healthy, :good_family, :good_job]) { ! p.too_clever? }

  ...
end

p = Person.new(:job => good_job, :family => good_family, :health => :good, :intellect => :too_clever)
p.good_job?                 # => true
p.good_family?              # => true
p.is_healthy?               # => true
p.fact_possible?(:is_happy) # => true (dependency satisfied)
p.is_happy?                 # => false

p.possible_facts - p.accomplished_facts # => [:happy]
```

## Description

The gem is most usefull when you have something
like a checklist, a list of tasks that your users should complete to achieve some goal. 

For example, let's say that in order to publish an article, user have to:

1. write the article
2. name the article (user may complete steps 1 & 2 in any order)
3. choose its category
4. assign tags to the article (user may complete steps 3 & 4 in any order, but only after steps 1 & 2)
5. mark article as ready for review (only after steps 1-3 are completed, but step 4 is not required)
6. recieve approvement from one of moderators (all steps 1-5 are required)

<!--- The imporant thing here - which makes fact_checker worth its use - is that you want to display this 
checklist for users in a way that they could instantly understand which steps are completed, which
is not accessible yet, and which are ready for action.
This means that each step could be in 3 different states: "completed", "ready for action" and "not accessible".
-->

Using fact_checker that could be implemented like this:

```ruby
include FactChecker

def_fact(:step1)                     { content.present? }
def_fact(:step2)                     { name.present? }
def_fact(:step3 => [:step1, :step2]) { category.present? }
def_fact(:step4 => [:step1, :step2]) { tag_list.present? }
def_fact(:step5 => :step3)           { ready_for_approvement? }
def_fact(:step6 => [:step4, :step5]) { approved? }

def state_of(step)
  return 'completed'         if fact_accomplished?(step) 
  return 'ready_for_action'  if fact_accessible(step)
  return 'not_accessible'
end
```

Just to compare, alternative implimentation without fact_checker:

``` ruby 
def step1_accessible?
  true
end
def step1_accomplished?
  content.present?
end
def step2_accessible?
  true
end
def step2_accomplished?
  name.present?
end
def step3_accessible?
  step1? && step2?
end
def step3_accomplished?
  step3_accessible? && a.category.present?
end
def step4_accessible?
  step1? && step2?
end
def step4_accomplished?
  step4_accessible? && tag_list.present?
end
def step5_accessible?
  step3
end
def step5_accomplished?
  step5_accessible? && a.ready_for_approvement?
end
def step6_accessible?
  step4? && step5
end
def step6_accomplished?
  step6_accessible? && a.approved?
end

def state_of(step)
  return 'completed'         if self.send(step + '_accomplished?')
  return 'ready_for_action'  if self.send(step + '_accessible?')
  return 'not_accessible'
end
```

## Installation

    gem install fact_checker
