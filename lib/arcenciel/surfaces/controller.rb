module Arcenciel
  module Surfaces
    class Controller
      include Logging

      attr_reader :name
      attr_reader :knobs

      attr_reader :device

      def self.from_dsl(&blk)
        new(DSL.eval(&blk))
      end

      def initialize(options)
        @name = options[:name] || default_name
        @knobs = options[:knobs] || []

        @device = nil
      end

      def assigned?
        !!@device
      end

      def assign!(device)
        log_info "Assigning controller '#{name}' to device..."

        @device = device
        knobs.each_with_index do |k, i|
          k.assign!(device, i)
          k.confirm!
        end

        device.attach!(self)
        device.validate!

        knobs.each do |k|
          k.first_update!
        end

        log_info "Assigned controller '#{name}'."
      end

      def unassign!
        @device = nil
        knobs.each(&:unassign!)
        log_notice "Controller '#{name}' is unassigned."
      end

      def on_delta(index, delta)
        return unless index < knobs.size
        knobs[index].on_delta(delta)
      end

      def on_key(index, state)
        return unless index < knobs.size
        knobs[index].on_key(state)
      end

      private

      def default_name
        'Arc'
      end
    end
  end
end
