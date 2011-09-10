# encoding: utf-8

class FactChecker::Base
  attr_accessor :facts, :dependencies, :requirements

  def initialize(facts = nil, deps = nil, reqs = nil)
    @facts        = facts || []
    @dependencies = deps  || {}
    @requirements = reqs  || {}
  end

  def initialize_copy
    super
    @facts = @facts.dup
    @dependencies = @dependencies.dup
    @requirements = @requirements.dup
  end

  # Checks if requirement and dependency for the fact are satisfied
  def fact_accomplished?(context, fact)
    fact_possible?(context, fact) && requirement_satisfied_for?(context, fact)
  end

  # Checks if dependency for the fact is satisfied
  def fact_possible?(context, fact)
    [* @dependencies[fact] || []].all?{ |dep| fact_accomplished?(context, dep) }
  end

  # Checks if requirement for the fact is satisfied (no dependency checks here)
  def requirement_satisfied_for?(context, fact)
    return false  unless @facts.include?(fact)

    req = @requirements[fact]

    if req.is_a?(Symbol)
      context.send(req)
    elsif req.is_a?(Proc)
      req.arity < 1 ? req.call : req.call(context)
    elsif req.nil?
      true
    else
      raise RuntimeError, "can't check this fact - wrong requirement"
    end
  end

  # Syntactic sugar, adds fact with its requirement and dependency. Examples:
  # - def_fact(:fact)
  # - def_fact(:fact, :if => :requirement)
  # - def_fact(:fact => :dependency)
  # - def_fact(:fact => :dependency, :if => :requirement)
  def def_fact(*opt)
    raise ArgumentError, "wrong number of arguments (#{opt.size} for 2)"  if opt.size > 2
    raise ArgumentError, "wrong number of arguments (0 for 1)"            if opt.size == 0

    if opt[0].is_a?(Hash)
      raise ArgumentError, "wrong arguments (hash argument can only be the last one)"  if opt.size > 1
      hash = opt[0]
    else
      raise ArgumentError, "wrong arguments (second argument must be a hash)" if opt[1] && ! opt[1].is_a?(Hash)
      hash = (opt[1] || {}).merge(opt[0] => nil)
    end

    req  = hash.delete(:if)
    fact = hash.keys.first
    dep  = hash.delete(fact)

    raise ArgumentError, "wrong arguments: #{hash.keys.join(', ')}"  if hash.size > 0

    @facts << fact  unless @facts.include?(fact)
    @requirements[fact] = req
    @dependencies[fact] = dep
  end

end
