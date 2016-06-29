require 'arcenciel/surfaces/base_knob'

module Arcenciel
  module Surfaces
    class Knob < BaseKnob
      include Logging

      DEFAULT_OPTIONS = {
        min:      0,
        max:      100,
        sweep:    360,
        type:     :float
      }

      attr_reader :name
      attr_reader :min
      attr_reader :max
      attr_reader :type
      attr_reader :sweep

      attr_reader :value
      attr_reader :counter
      attr_reader :precision
      attr_reader :depressed

      attr_reader :context
      attr_reader :device
      attr_reader :index

      def self.from_dsl(&blk)
        new(DSL.eval(&blk))
      end

      def initialize(options)
        super()
        options = DEFAULT_OPTIONS.merge(options)

        @name       = options[:name]
        @min        = options[:min]
        @max        = options[:max]
        @type       = options[:type]
        @sweep      = options[:sweep]
        @value      = options[:initial]

        @on_value   = options[:on_value]
        @on_push    = options[:on_push]
        @on_release = options[:on_release]

        @name       ||= default_name
        @value      ||= @min

        @precision  = precision_for_sweep(sweep)
        @counter    = counter_for_value(@value)

        @context = Context.new(self)

        clamp_counter
        update_value
        trigger_value
      end

      def typed_value
        integer_type? ?
          value.to_i :
          value.to_f
      end

      def confirm!
        start_chaser

        log_info "Illuminated knob '#{name}' (#{index}). Press any key."
        wait_for_key

        stop_chaser
        ring_clear
      end

      def first_update!
        update_ring
      end

      def on_delta(delta)
        @counter += delta
        clamp_counter

        update_value
        update_ring
        trigger_value
      end

      private

      def default_name
        'Unnamed'
      end

      def integer_type?
        type == :integer
      end

      def fraction_for_counter(x)
        x / precision.to_f
      end

      def value_for_counter(x)
        f = fraction_for_counter(x)
        (max - min) * f + min
      end

      def precision_for_sweep(x)
        (256 / 360.0 * x).to_i
      end

      def counter_for_value(x)
        ((x - min) / (max - min).to_f * precision.to_f).to_i
      end

      def clamp_counter
        @counter = 0 if @counter < 0
        @counter = precision if @counter > precision
      end

      def update_value
        @value = value_for_counter(counter)
      end

      def update_ring
        f = fraction_for_counter(counter)
        ring_fraction(f)
      end

      def trigger_value
        @on_value &&
          context.instance_exec(typed_value, &@on_value)
      end

      def on_push
        @on_push &&
          context.instance_exec(&@on_push)
      end

      def on_release
        @on_release &&
          context.instance_exec(&@on_release)
      end

      def ring_fraction(x)
        units = 64 * x
        count = units.to_i
        subpixel = units - units.to_i
        final_level = (15 * subpixel).to_i

        levels = []
        (0...count).each { levels << 15 }
        levels << final_level if levels.size < 64
        (levels.size...64).each { levels << 0 }

        device.ring_map(index, levels)
      end

      def start_chaser
        @chaser = Chaser.new(device, index)
        @chaser.start!
      end

      def stop_chaser
        @chaser.stop!
        @chaser = nil
      end

      def wait_for_key
        $stdin.noecho(&:gets)
      end
    end
  end
end
