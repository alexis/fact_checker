class FactChecker::Base
  attr_accessor :facts
  attr_accessor :deppendencies
  attr_accessor :requirements

  def initialize(facts, deps = nil, reqs = nil)
    @facts = facts
    @deppendencies = deps || {}
    @requirements = reqs || {}
  end

  def fact_accomplished?(context, fact)
    fact_possible?(context, fact) && requirement_satisfied_for?(context, fact)
  end

  def fact_possible?(context, fact)
    [* @deppendencies[fact] || []].all?{ |dep| fact_accomplished?(context, dep) }
  end

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
      raise FactChecker::Error, "wrong requirement type"
    end
  end

end
