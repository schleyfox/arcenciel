require 'thread'

module Arcenciel
  class Chaser
    MAX_LEVEL = 13

    SEQUENCE = (1..5).to_a.reverse.map do |i|
      (MAX_LEVEL * 1.0 / (i * i)).to_i
    end

    attr_reader :device
    attr_reader :index

    def self.position
      @position ||= 0
    end

    def self.advance
      @position ||= 0
      @position += 1
      @position %= 64
    end

    def initialize(device, index)
      @device = device
      @index = index

      @running = false
      @thread = nil
    end

    def running?
      !!@running
    end

    def start!
      return if running?
      @running = true
      ring_clear
      run_async
    end

    def stop!
      return if !running?
      @running = false
      join_async
      ring_clear
    end

    private

    def run_async
      @thread = Thread.start do
        run_loop
      end
    end

    def join_async
      @thread.join
      @thread = nil
    end

    def run_loop
      while running?
        advance
        update
        sleep 0.02
      end
    end

    def advance
      self.class.advance
    end

    def update
      pos = self.class.position
      (0...4).each do |e|
        SEQUENCE.each_with_index do |level, i|
          x = (pos + 16 * e + i) % 64
          ring_set(x, level)
        end
      end
    end

    def ring_clear
      device.ring_clear(index)
    end

    def ring_set(x, level)
      device.ring_set(index, x, level)
    end
  end
end
