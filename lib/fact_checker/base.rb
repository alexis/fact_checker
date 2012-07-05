# encoding: utf-8

require 'delegate'

module FactChecker
  class Base
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
      fact = ensure_symbol fact
      fact_possible?(context, fact) && requirement_satisfied_for?(context, fact)
    end

    # Checks if dependency for the fact is satisfied
    def fact_possible?(context, fact)
      fact = ensure_symbol fact
      [* @dependencies[fact] || []].all?{ |dep| fact_accomplished?(context, dep) }
    end

    # Checks if requirement for the fact is satisfied (no dependency checks here)
    def requirement_satisfied_for?(context, fact)
      fact = ensure_symbol fact
      return false unless @facts.include?(fact)

      case req = @requirements[fact]
      when Symbol   then context.public_send(req)
      when Proc     then req.arity < 1 ? context.instance_exec(&req) : req.call(context)
      when NilClass then true
      else raise RuntimeError, "can't check this fact - wrong requirement"
      end
    end

    # Syntactic sugar, adds fact with its requirement and dependency. Examples:
    # - def_fact(:fact)
    # - def_fact(:fact, :if => :requirement)
    # - def_fact(:fact => :dependency)
    # - def_fact(:fact => :dependency, :if => :requirement)
    def def_fact(*opt)
      raise ArgumentError, "wrong number of arguments (#{opt.size} for 2)" if opt.size > 2
      raise ArgumentError, "wrong number of arguments (0 for 1)"           if opt.size == 0

      if opt[0].is_a?(Hash)
        raise ArgumentError, "wrong arguments (hash argument can only be the last one)" if opt.size > 1
        hash = opt[0]
      else
        raise ArgumentError, "wrong arguments (second argument must be a hash)" if opt[1] && ! opt[1].is_a?(Hash)
        hash = (opt[1] || {}).merge(opt[0] => nil)
      end

      req  = hash.delete(:if)
      fact = ensure_symbol hash.keys.first
      dep  = hash.delete(hash.keys.first)

      raise ArgumentError, "wrong arguments: #{hash.keys.join(', ')}" if hash.size > 0

      @requirements[fact] = req
      @dependencies[fact] = dep
      @facts |= [fact]

      fact_functor_obj fact
    end

    private

      def ensure_symbol(fact_name)
        unless [Symbol, String].include? fact_name.class
          fail ArgumentError, 'fact_name is not of class Symbol or String'
        end

        fact_name.to_sym
      end

      def fact_functor_obj(fact_name)
        fact_obj = SimpleDelegator.new(fact_name.to_s)
        def fact_obj.is_private?; start_with? '_'; end
        fact_obj
      end
  end
end
