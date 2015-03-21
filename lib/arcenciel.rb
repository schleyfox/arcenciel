require 'osc-ruby'
require 'colored'

require 'arcenciel/utility'
require 'arcenciel/manager'
require 'arcenciel/control'
require 'arcenciel/encoder'

module Arcenciel
  # Lists all controls
  def self.controls
    @controls ||= []
  end

  # Add a new control
  def self.add(&blk)
    controls << Control.from_dsl(&blk)
  end

  # Run the event loop
  def self.run!(&blk)
    add(&blk) if block_given?
    Manager.run!(controls)
  end
end
