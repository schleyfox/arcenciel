require 'thread'

module Arcenciel
  class Hub
    attr_reader :serial_port
    attr_reader :server_port

    attr_reader :client
    attr_reader :server

    def initialize
      @serial_port = 12002
      @server_port = 10210

      @client = OSC::Client.new('localhost', serial_port)
      @server = OSC::Server.new(server_port)
    end

    def run!
      Thread.start do
        server.run
      end
    end

    def send(command)
      client.send(OSC::Message.new(command, 'localhost', server_port))
    end

    def listen(path, &blk)
      server.add_method(path, &blk)
    end
  end
end
