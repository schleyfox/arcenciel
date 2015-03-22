require 'osc-ruby'

require 'arcenciel/utility'
require 'arcenciel/manager'
require 'arcenciel/surfaces'

module Arcenciel

  # Lists all controllers.
  def self.controllers
    @controllers ||= []
  end

  # Add a new controllers.
  def self.add(&blk)
    controllers << Surfaces::Controller.from_dsl(&blk)
  end

  # Run the main event loop.
  def self.run!(&blk)
    add(&blk) if block_given?
    Manager.run!(controllers)
  end

  # Set the controller lifecycle logger.
  def self.logger=(logger)
    Logging.logger = logger
  end

end
