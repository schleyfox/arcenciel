require 'io/console'

module Arcenciel
  class Encoder
    include Logging

    attr_reader :name

    attr_reader :min
    attr_reader :max

    attr_reader :precision
    attr_reader :mode

    attr_reader :on_value
    attr_reader :on_push
    attr_reader :on_release

    attr_reader :value
    attr_reader :counter
    attr_reader :depressed

    attr_reader :device
    attr_reader :index

    class DSL < DSLBase

      def name(name)
        opts[:name] = name
      end

      def initial(value)
        opts[:initial] = value
      end

      def min(value)
        opts[:min] = value
      end

      def max(value)
        opts[:max] = value
      end

      def range(range)
        opts[:min] = range.begin
        opts[:max] = range.end
      end

      def precision(count)
        opts[:precision] = count
      end

      def mode(mode)
        opts[:mode] = mode
      end

      def on_value(&blk)
        opts[:on_value] = blk
      end

      def on_push(&blk)
        opts[:on_push] = blk
      end

      def on_release(&blk)
        opts[:on_release] = blk
      end

    end

    def self.from_dsl(&blk)
      new(DSL.eval(&blk))
    end

    def initialize(options)
      @name = options[:name] || default_name

      @min = options[:min] || 0
      @max = options[:max] || 100

      @precision = options[:precision] || 1024  # 4 * 256
      @mode = options[:mode] || :auto

      @on_value   = options[:on_value]   || Proc.new {}
      @on_push    = options[:on_push]    || Proc.new {}
      @on_release = options[:on_release] || Proc.new {}

      @value = options[:initial] || @min
      @counter = counter_for_value(@value)
      @depressed = false

      @device = nil
      @index = nil

      clamp_counter
      update_value
    end

    def assigned?
      !!@device
    end

    def assign!(device, index)
      @device = device
      @index = index
    end

    def unassign!
      @device = nil
      @index = nil
    end

    def confirm!
      start_chaser
      log_info "Illuminated encoder '#{name}' (#{index}). Press any key."
      STDIN.noecho(&:gets)
      stop_chaser
      ring_clear
    end

    def first_update!
      update_ring
    end

    def on_delta(delta)
      apply_delta(delta)
      on_value.call(value)
    end

    def on_key(state)
      case state
      when 0
        @depressed = false
        on_release.call
      when 1
        @depressed = true
        on_push.call
      end
    end

    private

    def default_name
      'unnamed'
    end

    def apply_delta(delta)
      @counter += delta
      clamp_counter
      update_value
      update_ring
    end

    def clamp_counter
      @counter = 0 if @counter < 0
      @counter = precision if @counter > precision
    end

    def fraction_for_counter(x)
      x / precision.to_f
    end

    def value_for_counter(x)
      f = fraction_for_counter(x)
      (max - min) * f + min
    end

    def counter_for_value(x)
      ((x - min) / (max - min).to_f * precision.to_f).to_i
    end

    def update_value
      @value = value_for_counter(counter)
    end

    def update_ring
      f = fraction_for_counter(counter)
      ring_fraction(f)
    end

    def ring_clear
      device.ring_clear(index)
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
  end
end
