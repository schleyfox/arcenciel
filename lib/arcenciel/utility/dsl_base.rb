module Arcenciel
  class DSLBase
    attr_reader :opts

    def self.eval(&blk)
      dsl = new
      dsl.instance_eval(&blk)
      dsl.opts
    end

    def initialize
      @opts = {}
    end
  end
end
