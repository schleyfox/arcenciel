module Arcenciel
  class Control
    include Logging

    attr_reader :name
    attr_reader :encoders

    attr_reader :device

    class DSL < DSLBase

      def name(name)
        opts[:name] = name
      end

      def encoder(&blk)
        opts[:encoders] ||= []
        opts[:encoders] << Encoder.from_dsl(&blk)
      end

    end

    def self.from_dsl(&blk)
      new(DSL.eval(&blk))
    end

    def initialize(options)
      @name = options[:name] || default_name
      @encoders = options[:encoders] || []
      
      @device = nil
    end

    def assigned?
      !!@device
    end

    def assign!(device)
      log_info "Assigning control '#{name}' to device..."

      @device = device
      encoders.each_with_index do |e, i|
        e.assign!(device, i)
        e.confirm!
      end

      device.attach!(self)
      device.validate!

      encoders.each do |e|
        e.first_update!
      end

      log_info "Assigned control '#{name}'."
    end

    def unassign!
      @device = nil
      encoders.each(&:unassign!)
      log_info "Control '#{name}' is unassigned."
    end

    def on_delta(index, delta)
      return unless index < encoders.size
      encoders[index].on_delta(delta)
    end

    def on_key(index, state)
      return unless index < encoders.size
      encoders[index].on_key(state)
    end

    private

    def default_name
      'arc'
    end
  end
end
