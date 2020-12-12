module Pubsueque
  class Scheduler
    def initialize(processor, time)
      @time = time
      @processor = processor
    end

    def schedule
      # Could have used Redis to queue delayed jobs, but wanted to keep dependencies at minimum.
      # ActiveJob's Async adapter uses this to schedule jobs.
      # Does the job (we have a pub/sub backend so we won't be loosing jobs).
      Concurrent::ScheduledTask.execute @time, &@processor.method(:process)
    end

    def self.schedule(processor, time)
      new(processor, time)
    end
  end
end
