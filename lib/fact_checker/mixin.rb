# encoding: utf-8

module FactChecker
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def define_fact(arg, &block)
      fail ArgumentError, 'block not supplied'  unless block

      name, dependencies = arg.is_a?(Hash) ? arg.to_a.flatten(1) : [arg, []]

      (@fact_checker_facts ||= []) << name.to_sym

      define_method(name) do
        dependencies_satisfied = [*dependencies].all?{ |dep_name| send(dep_name).valid? }
        Result.new(dependencies_satisfied, instance_eval(&block))
      end

      define_method("#{name}?") do
        send(name).valid?
      end

      private name, "#{name}?"  if name[0] == '_'
    end

    def facts
      ancestors.reverse.map{ |klass| klass.instance_eval{ @fact_checker_facts } }.compact.flatten(1)
    end
  end
end
