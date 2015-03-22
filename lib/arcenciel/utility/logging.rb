require 'logger'
require 'colored'

module Arcenciel
  module Logging

    class << self
      attr_writer :logger

      def logger
        @logger ||= DEFAULT_LOGGER
      end
    end

    def logger
      Logging.logger
    end

    def log_info(msg)
      logger.info(msg)
    end

    def log_warn(msg)
      logger.warn(msg)
    end

    def log_error(msg)
      logger.error(msg)
    end

    class DefaultFormater
      SEVERITY_CONFIG = {
        'INFO'  => ['ARC', :blue],
        'WARN'  => ['WARN', :red],
        'ERROR' => ['ERROR', :red],
        'FATAL' => ['FATAL', :red],
        'DEBUG' => ['DEBUG', :blue]
      }

      def call(severity, time, progname, msg)
        tag, color = SEVERITY_CONFIG[severity]
        colored_tag = Colored.colorize(tag, foreground: color)

        string = ''
        string += "[#{progname}] " if progname
        string += "[#{colored_tag}] "
        string += msg
        string += "\n"

        string
      end
    end

    DEFAULT_LOGGER = Logger.new($stdout).tap do |l|
      l.formatter = DefaultFormater.new
    end
  end
end
