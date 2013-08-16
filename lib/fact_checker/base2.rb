# encoding: utf-8

module FactChecker
  class Base2
    attr_accessor :facts, :dependencies, :requirements

    def initialize(facts = nil, deps = nil, reqs = nil)
      @facts        = facts || []
      @dependencies = deps  || {}
      @requirements = reqs  || {}
    end

    def initialize_copy(orig)
      super
      @facts = orig.facts.dup
      @dependencies = orig.dependencies.dup
      @requirements = orig.requirements.dup
    end

    # Checks if requirement for the fact is satisfied (no dependency checks here)
    def requirement_satisfied_for?(fact)
      fact = ensure_symbol(fact)
      req  = @requirements[fact]

      return false  unless @facts.include?(fact)
      return true   if req.nil?
      fail RuntimeError, "requirement #{req} is not callable"  unless req.respond_to?(:call)

      instance_eval &req
    end

    def check_requirement(req)
      instance_eval &req
    end

    # Checks if requirement and dependency for the fact are satisfied
    def fact_accomplished?(fact)
      fact = ensure_symbol(fact)
      fact_possible?(fact) && requirement_satisfied_for?(fact)
    end

    # Checks if dependency for the fact is satisfied
    def fact_possible?(fact)
      fact = ensure_symbol(fact)
      [* @dependencies[fact] || []].all?{ |dep| fact_accomplished?(dep) }
    end

    def accomplished_facts
      facts.select{ |fact| fact_accomplished?(fact) }
    end

    def possible_facts
      facts.select{ |fact| fact_possible?(fact) }
    end

    # Syntactic sugar, adds fact with its requirement and dependency. Examples:
    # - def_fact(:fact)
    # - def_fact(:fact) {...}
    # - def_fact(:fact => :dependency)
    # - def_fact(:fact => :dependency) {...}
    def def_fact(opt, &block)
      hash = opt.is_a?(Hash) ? opt : {opt => nil}

      req  = block
      fact = ensure_symbol(hash.keys.first)
      dep  = hash.delete(hash.keys.first)

      raise ArgumentError, "wrong arguments: #{hash.keys.join(', ')}" if hash.size > 0

      @requirements[fact] = req
      @dependencies[fact] = dep
      @facts |= [fact]

      fact
    end

    private

    def ensure_symbol(fact_name)
      raise ArgumentError, "fact_name can't be converted to symbol"  unless fact_name.respond_to?(:to_sym)
      fact_name.to_sym
    end
  end
end
