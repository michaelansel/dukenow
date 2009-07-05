require 'rubygems'
require 'spec'

module Spec
  module Example
    class ExampleGroupHierarchy
      def validation_blocks
        @validation_blocks ||= collect {|klass| klass.validation_blocks}.flatten
      end
    end

    module ExampleGroupMethods
      def it_can(*capabilities)
        capabilities.each do |c|
          include_capability(c)
        end
      end
      def it_can_be(*capabilities)
        capabilities.each do |c|
          it_can("be #{c}")
        end
      end
  
      def in_order_to(*args, &block)
        raise Spec::Example::NoDescriptionError.new("example group", caller(0)[1]) if args.empty?
        options = add_options(args)
        set_location(options, caller(0)[1])
        Spec::Example::CapabilityFactory.create_capability(*args, &block)
      end
      def in_order_to_be(*args, &block)
        in_order_to("be", *args, &block)
      end
  
  
      def include_capability(capability)

        unless example_group = Capability.find(capability)
          raise RuntimeError.new("Capability '#{capability}' can not be found")
        end

        subclass("can",capability,"therefore") do
          include example_group

          describe("when set up properly") do
            ExampleGroupHierarchy.new(self).validation_blocks.each do |validation_block|
              self.module_eval(&validation_block)
            end
          end
        end
      end

      def validation_blocks
        @validation_blocks ||= []
      end

      def validate_setup(&block)
        validation_blocks << block
      end
  
    end
  
    class Capability < SharedExampleGroup
    end

    class CapabilityFactory < ExampleGroupFactory
      def self.create_capability(*args, &capability_block) # :nodoc:
        ::Spec::Example::Capability.register(*args,&capability_block)
      end 
    end
  end
end
