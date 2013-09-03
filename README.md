# Fact Checker [![Build Status](https://secure.travis-ci.org/alexis/fact_checker.png?branch=master)](http://travis-ci.org/alexis/fact_checker) [![Code Climate](https://codeclimate.com/github/alexis/fact_checker.png)](https://codeclimate.com/github/alexis/fact_checker)

  Simple ruby gem to define and check hierarchically dependent "facts" about objects.

## Synopsys

``` ruby
class Person
  include FactChecker

  define_fact(:good_job)    { p.job.good? }
  define_fact(:good_family) { p.family.good? }
  define_fact(:is_healthy)  { p.health.good? }
  define_fact(:is_happy => [:is_healthy, :good_family, :good_job]) { ! p.too_clever? }

  ...
end

p = Person.new(job: good_job, family: good_family, health: :good, intellect: :too_clever)
p.good_job?                     # => true
p.good_family?                  # => true
p.is_healthy?                   # => true
p.is_happy.available?           # => true (dependency satisfied)
p.is_happy?                     # => false
```

## Description

The gem is most usefull when you have something
like a checklist, a list of tasks that your users should complete to achieve some goal. 

For example, let's say that in order to publish an article a user has to:

1. write the article
2. name the article (user may complete steps 1 & 2 in any order)
3. choose its category
4. assign tags to the article (user may complete steps 3 & 4 in any order, but only after steps 1 & 2)
5. mark article as "ready for review" (only after steps 1-3 are completed, but step 4 is not required)
6. recieve approvement from one of moderators (all steps 1-5 are required)

<!--- The imporant thing here - which makes fact_checker worth its use - is that you want to display this 
checklist for users in a way that they could instantly understand which steps are completed, which
is not available yet, and which are ready for action.
This means that each step could be in 3 different states: "completed", "ready for action" and "not available".
-->

Using fact_checker that logic could be implemented like this:

```ruby
include FactChecker

define_fact(:step1)                     { content.present? }
define_fact(:step2)                     { name.present? }
define_fact(:step3 => [:step1, :step2]) { category.present? }
define_fact(:step4 => [:step1, :step2]) { tag_list.present? }
define_fact(:step5 => :step3)           { ready_for_approvement? }
define_fact(:step6 => [:step4, :step5]) { approved? }

def state_of(step)
  return 'completed'         if public_send(step).valid?
  return 'ready_for_action'  if public_send(step).available?
  return 'not_available'
end
```

Just to compare, a possible alternative implimentation without fact_checker:

``` ruby
def step1_available?
  true
end
def step1_valid?
  content.present?
end
def step2_available?
  true
end
def step2_valid?
  name.present?
end
def step3_available?
  step1? && step2?
end
def step3_valid?
  step3_available? && a.category.present?
end
def step4_available?
  step1? && step2?
end
def step4_valid?
  step4_available? && tag_list.present?
end
def step5_available?
  step3
end
def step5_valid?
  step5_available? && a.ready_for_approvement?
end
def step6_available?
  step4? && step5
end
def step6_valid?
  step6_available? && a.approved?
end

def state_of(step)
  return 'completed'         if self.public_send(step + '_valid?')
  return 'ready_for_action'  if self.public_send(step + '_available?')
  return 'not_available'
end
```

## Installation

    gem install fact_checker
