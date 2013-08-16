# encoding: utf-8

module FactChecker
  class Definition
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

    def accomplished_facts(context)
      facts.select{ |fact| fact_accomplished?(context, fact) }
    end

    def possible_facts(context)
      facts.select{ |fact| fact_possible?(context, fact) }
    end

    # Checks if requirement and dependency for the fact are satisfied
    def fact_accomplished?(context, fact)
      fact = ensure_symbol(fact)
      fact_possible?(context, fact) && requirement_satisfied_for?(context, fact)
    end

    # Checks if dependency for the fact is satisfied
    def fact_possible?(context, fact)
      fact = ensure_symbol(fact)
      [* @dependencies[fact] || []].all?{ |dep| fact_accomplished?(context, dep) }
    end

    # Checks if requirement for the fact is satisfied (no dependency checks here)
    def requirement_satisfied_for?(context, fact)
      fact = ensure_symbol(fact)
      return false unless @facts.include?(fact)

      case req = @requirements[fact]
      when Proc     then req.arity < 1 ? req.call : req.call(context)
      when NilClass then true
      else raise RuntimeError, "can't check this fact - wrong requirement"
      end
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
