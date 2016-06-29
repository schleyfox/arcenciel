require 'arcenciel/surfaces/controller'
require 'arcenciel/surfaces/base_knob'
require 'arcenciel/surfaces/knob'

module Arcenciel
  module Surfaces

    class Controller

      class DSL < DSLBase

        # Set the name of this logical controller.
        def name(name)
          opts[:name] = name
        end

        # Add a new logical knob (encoder) to the controller.
        def knob(&blk)
          base_knob(Knob.from_dsl(&blk))
        end

        def base_knob(knob)
          opts[:knobs] ||= []
          opts[:knobs] << knob
        end
      end

    end

    class Knob

      class DSL < DSLBase

        # Set the name of this logical knob (encoder).
        def name(name)
          opts[:name] = name
        end

        # Set the initial value of the knob.
        # Default - Minimum value
        def initial(value)
          opts[:initial] = value
        end

        # Set the range of values for the knob.
        def range(range)
          opts[:min] = range.begin
          opts[:max] = range.end
        end

        # Set the minimum value of the knob.
        # Default - 0
        def min(value)
          opts[:min] = value
        end

        # Set the maximum value of the knob.
        # Default - 100
        def max(value)
          opts[:max] = value
        end

        # Set the type of value (:integer or :float).
        # Default - :float
        def type(type)
          opts[:type] = type
        end

        # Set the precision of the knob (degrees per sweep).
        # Default - 360 (one rotation per sweep)
        def sweep(degrees)
          opts[:sweep] = degrees
        end

        # Set the callback invoked when the value changes.
        def on_value(&blk)
          opts[:on_value] = blk
        end

        # Set the callback invoked when the knob is depressed.
        def on_push(&blk)
          opts[:on_push] = blk
        end

        # Set the callback invoked when the knob is released.
        def on_release(&blk)
          opts[:on_release] = blk
        end

      end

      class Context

        def initialize(knob)
          @knob = knob
        end

        # Returns the name of this logical knob (encoder).
        def name
          @knob.name
        end

        # Returns the value of this knob.
        def value
          @knob.typed_value
        end

      end

    end

  end
end
