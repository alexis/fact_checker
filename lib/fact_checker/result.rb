# encoding: utf-8

module FactChecker
  class Result
    def initialize(dependency_state, requirement_state)
      @dependency_state = dependency_state
      @requirement_state = requirement_state
    end

    def valid?
      @dependency_state && @requirement_state
    end

    def available?
      @dependency_state
    end
  end
end
