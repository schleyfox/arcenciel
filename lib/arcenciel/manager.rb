require 'thread'

require 'arcenciel/manager/device'
require 'arcenciel/manager/hub'

module Arcenciel
  class Manager
    include Logging

    attr_reader :controls
    attr_reader :devices

    def self.run!(controls)
      new(controls).run!
    end

    def initialize(controls)
      @controls = controls

      @hub = Hub.new
      @mutex = Mutex.new
      @shutdown = false

      @id_map = {}
      @port_map = {}
    end

    def devices
      @id_map.values
    end

    def run!
      trap_signals

      add_listeners
      list_devices
      begin_notify

      start_hub
      run_loop
    ensure
      clear_devices
    end

    def shutdown!
      @shutdown = true
    end

    def shutdown?
      !!@shutdown
    end

    private

    def trap_signals
      Signal.trap('INT')  { shutdown! }
      Signal.trap('TERM') { shutdown! }
    end

    def run_loop
      until shutdown?
        assign_devices
        sleep 0.1
      end
    end

    def assign_devices
      devices.each do |device|
        next if device.attached?
        begin
          if control = controls.first(&:assigned?)
            control.assign!(device)
          end
        rescue Device::InvalidDeviceError
          control.unassign!
        end
      end
    end

    def clear_devices
      devices.each do |device|
        begin
          device.ring_clear_all
        rescue
        end
      end
    end

    def start_hub
      @hub.run!
    end

    def add_listeners
      listen('/serialosc/add',    :process_add)
      listen('/serialosc/remove', :process_remove)
      listen('/serialosc/device', :process_device)
      listen('/arc/enc/delta',    :process_delta)
      listen('/arc/enc/key',      :process_key)
    end

    def listen(path, name)
      @hub.listen(path, &method(name))
    end

    def list_devices
      @hub.send('/serialosc/list')
    end

    def begin_notify
      @hub.send('/serialosc/notify')
    end

    def add_device(device)
      return if @id_map.include?(device.id)

      @id_map[device.id] = device
      @port_map[device.port] = device
      device.start!(@hub.server_port)
    end

    def remove_device(id)
      if device = @id_map.delete(id)
        @port_map.delete(device.port)
        device.stop!
      end
    end

    def dispatch_delta(port, index, delta)
      if device = @port_map[port]
        device.on_delta(index, delta)
      end
    end

    def dispatch_key(port, index, state)
      if device = @port_map[port]
        device.on_key(index, state)
      end
    end

    def process_add(msg)
      list_devices
      begin_notify
    end

    def process_remove(msg)
      id = msg.to_a[0]

      @mutex.synchronize do
        remove_device(id)
        begin_notify
      end
    end

    def process_device(msg)
      id, type, port = msg.to_a
      device = Device.new(id, type, port)

      if device.arc?
        @mutex.synchronize do
          add_device(device)
        end
      end
    end

    def process_delta(msg)
      port = msg.ip_port
      args = msg.to_a
      index = args[0].to_i
      delta = args[1].to_i

      @mutex.synchronize do
        dispatch_delta(port, index, delta)
      end
    end

    def process_key(msg)
      port = msg.ip_port
      args = msg.to_a
      index = args[0].to_i
      state = args[1].to_i

      @mutex.synchronize do
        dispatch_key(port, index, state)
      end
    end
  end
end
