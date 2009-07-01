require 'rubygems'
require 'spec'

module Spec
  module Example
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
        Spec::Example::CapabilityFactory.create_capability(*args, &block)
      end
      def in_order_to_be(*args, &block)
        in_order_to("be", *args, &block)
      end
  
  
      def include_capability(capability)
        case capability
        when Capability
          include capability
        else
          unless example_group = Capability.find(capability)
            raise RuntimeError.new("Capability '#{capability}' can not be found")
          end
          include(example_group)
        end
      end
  
    end
  
    class Capability < SharedExampleGroup
    end

    class CapabilityFactory < ExampleGroupFactory
      def self.create_capability(*args, &example_group_block) # :nodoc:
        ::Spec::Example::Capability.register(*args, &example_group_block)
      end 
    end
  end
end
