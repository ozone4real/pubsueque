module Pubsueque
  class Logger
    def self.log(message)
      STDOUT.print("#{message}\n")
    end
  end
end
