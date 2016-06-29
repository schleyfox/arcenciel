require 'io/console'

module Arcenciel
  module Surfaces
    class BaseKnob
      attr_reader :device
      attr_reader :index
      attr_reader :depressed

      def initialize
        @device = nil
        @index = nil
      end

      def assigned?
        !!@device
      end

      def assign!(device, index)
        @device = device
        @index = index
        @depressed = false
      end

      def unassign!
        @device = nil
        @index = nil
      end

      def confirm!
      end

      def first_update!
      end

      def on_delta(delta)
      end

      def on_key(state)
        case state
        when 0
          @depressed = false
          on_release
        when 1
          @depressed = true
          on_push
        end
      end

      def on_push
      end

      def on_release
      end

      private

      def ring_clear
        device.ring_clear(index)
      end
    end
  end
end
