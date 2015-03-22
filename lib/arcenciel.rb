require 'osc-ruby'
require 'colored'

require 'arcenciel/utility'
require 'arcenciel/manager'
require 'arcenciel/surfaces'

module Arcenciel
  # Lists all controls
  def self.controllers
    @controls ||= []
  end

  # Add a new control
  def self.add(&blk)
    controllers << Surfaces::Controller.from_dsl(&blk)
  end

  # Run the event loop
  def self.run!(&blk)
    add(&blk) if block_given?
    Manager.run!(controllers)
  end
end
