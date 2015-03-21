module Arcenciel
  module Logging

    def log_info(string)
      log_with_tag(string, 'ARC', :yellow)
    end

    def log_error
      log_with_tag(string, 'ERROR', :red)
    end

    private

    def log_with_tag(string, tag, color)
      colored_tag = Colored.colorize(tag, foreground: color)
      puts '[' + colored_tag + '] ' + string
    end

  end
end
