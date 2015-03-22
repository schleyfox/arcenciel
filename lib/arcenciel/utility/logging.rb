module Arcenciel
  module Logging
    def log_info(string)
      log_with_tag(string, 'ARC', :blue)
    end

    def log_notice(string)
      log_with_tag(string, 'NOTICE', :red)
    end

    def log_error(string)
      log_with_tag(string, 'ERROR', :red)
    end

    private

    def log_with_tag(string, tag, color)
      colored_tag = Colored.colorize(tag, foreground: color)
      puts '[' + colored_tag + '] ' + string
    end
  end
end
