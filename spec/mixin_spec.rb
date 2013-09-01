# encoding: utf-8

require 'spec_helper'

describe FactChecker do
  context "when included into a class" do

    let(:klass) { Class.new { include FactChecker } }

    describe ".facts" do
      it "exists" do
        expect(klass.superclass.methods).to_not include(:facts)
        expect(klass.methods).to include(:facts)
      end

      it "returns [] when no facts were defined" do
        expect(klass.facts).to eq([])
      end

      it "returns list of all defined facts names" do
        klass.class_eval do
          define_fact(:x) {}
          define_fact(:y => [:x, :x1]) {}
        end

        expect(klass.facts).to eq([:x, :y])
      end

      it "returns independent results for independent classes" do
        klass1 = Class.new { include FactChecker; define_fact(:x) {} }
        klass2 = Class.new { include FactChecker; define_fact(:y) {} }
        expect(klass1.facts).to eq([:x])
        expect(klass2.facts).to eq([:y])
      end

      it "returns one-way dependent results for superclass and subclasses" do
        klass1 = Class.new { include FactChecker; define_fact(:x) {} }
        klass2 = Class.new(klass1) { define_fact(:y) {} }
        klass3 = Class.new(klass2) { define_fact(:z) {} }
        klass1.class_eval { define_fact(:q) {} }

        expect(klass1.facts).to eq([:x, :q])
        expect(klass2.facts).to eq([:x, :q, :y])
        expect(klass3.facts).to eq([:x, :q, :y, :z])
      end
    end


    describe ".define_fact" do
      it "exists" do
        expect(klass.superclass.methods).to_not include(:define_fact)
        expect(klass.methods).to include(:define_fact)
      end

      context "when called with no arguments" do
        it "raises an ArgumentError" do
          expect{klass.define_fact}.to raise_error(ArgumentError)
        end
      end

      context "when called with (:name)" do
        it "raises an ArgumentError" do
          expect{klass.define_fact(:x)}.to raise_error(ArgumentError)
        end
      end

      context "when called with (:name, &block)" do
        it "behaves as if it was called with (:name => [], &block)" do
          klass.define_fact(:x) { :result }
          expect(klass.instance_methods).to include(:x)
          expect(klass.instance_methods).to include(:x?)
          expect(klass.new.x.valid?).to be(:result)
          expect(klass.new.x.available?).to be(true)
          expect(klass.new.x?).to be(:result)
        end
      end

      context "when called with (:name => :dependency_name, &block)" do
        it "behaves as if it was called with (:name => [:dependency_name], &block)" do
          klass.define_fact(:y) { false }
          klass.define_fact(:x => :y) { :result }
          expect(klass.instance_methods).to include(:x)
          expect(klass.instance_methods).to include(:x?)
          expect(klass.new.x.valid?).to be(false)
          expect(klass.new.x.available?).to be(false)
          expect(klass.new.x?).to be(false)

          klass.define_fact(:y) { true }
          klass.define_fact(:x => :y) { :result }
          expect(klass.new.x.valid?).to be(:result)
          expect(klass.new.x.available?).to be(true)
          expect(klass.new.x?).to be(:result)
        end
      end

      context "when called with (:name => dependencies, &block)" do
        it "defines an instance method #name" do
          expect(klass.instance_methods).to_not include(:x)
          klass.define_fact(:x => []) {}
          expect(klass.instance_methods).to include(:x)
        end

        it "defines an instance method #name?" do
          expect(klass.instance_methods).to_not include(:x?)
          klass.define_fact(:x => []) {}
          expect(klass.instance_methods).to include(:x?)
        end

        context "where the newly defined instance methods" do
          let(:instance) { klass.new }

          describe "#<name>" do
            it "returns an object of FactChecker::Result" do
              klass.define_fact(:x => []) {}
              expect(instance.x).to be_a_kind_of(FactChecker::Result)
            end

            it "evaluates block in the context of the current instance" do
              klass.define_fact(:x => []) { check? }
              klass.class_eval { def check?; end }
              expect(instance).to receive(:check?).and_call_original
              instance.x
            end

            context "when the :name fact has blank dependencies" do
              before(:each) { klass.define_fact(:x => []) {:result} }

              it "returns result with .valid? == block.call" do
                expect(instance.x.valid?).to be(:result)
              end

              it "returns result with .available? == true" do
                expect(instance.x.available?).to be_true
              end
            end

            context "when the :name fact has valid dependencies" do
              before(:each) do
                klass.class_eval do
                  define_fact(:x) { true }
                  define_fact(:y) { :truthy }
                  define_fact(:z => [:x, :y]) { :result }
                end
              end

              it "returns result with .valid? == block.call" do
                expect(instance.z.valid?).to be(:result)
              end

              it "returns result with .available? == true" do
                expect(instance.z.available?).to be_true
              end
            end

            context "when the :name fact has at least 1 invalid dependency" do
              before(:each) do
                klass.class_eval do
                  define_fact(:x) { true }
                  define_fact(:y) { false }
                  define_fact(:z => [:x, :y]) { :something }
                end
              end

              it "returns result with .valid? == false" do
                expect(instance.z.valid?).to be(false)
              end

              it "returns result with .available? == false" do
                expect(instance.z.available?).to be(false)
              end
            end

            context "when the :name fact has dependencies inherited from a superclass" do
              it "return correct results" do
                klass1 = Class.new(klass)
                klass.define_fact(:x) { true }
                klass.define_fact(:y) { false }
                klass1.define_fact(:z1 => [:x, :y]) { true }
                klass1.define_fact(:z2 => [:x]) { true }
                klass1.define_fact(:z3 => [:x]) { false }
                instance = klass1.new

                expect(instance.z1.valid?).to be(false)
                expect(instance.z1.available?).to be(false)
                expect(instance.z2.valid?).to be(true)
                expect(instance.z3.available?).to be(true)
                expect(instance.z3.valid?).to be(false)
                expect(instance.z2.available?).to be(true)
              end
            end
          end

          describe "#<name>?" do
            it "delegates to name.valid?" do
              klass.define_fact(:x) {}
              result = double(:valid? => :yeah!)
              expect(instance).to receive(:x).and_return(result)
              expect(instance.x?).to be(:yeah!)
            end
          end
        end
      end

      context "when called with (:_underscored_name => dependencies, &block)" do
        it "marks new #_underscored_name method as private" do
          klass.define_fact(:_x) {}
          expect{ klass.new._x }.to raise_error
        end

        it "marks new #_undersrored_name? method as private" do
          klass.define_fact(:_x) {}
          expect{ klass.new._x? }.to raise_error
        end
      end
    end

  end
end

