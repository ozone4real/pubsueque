require 'concurrent/scheduled_task'

module Pubsueque
  class FailedJobsConsumer
    def initialize(options)
      @options = options
      @queue = Queue.new
    end

    def <<(work)
      @queue.push work
    end

    def init
      Thread.new do
        loop do
          processor = @queue.pop
          # Could have used Redis to queue delayed jobs, but wanted to keep dependencies at minimum. 
          # ActiveJob's Async adapter uses this for delayed jobs.
          # Does the job (we have a pub/sub backend so we won't be loosing jobs).
          Concurrent::ScheduledTask.execute @options[:retry_interval], &processor.method(:process)
        end
      end
    end
  end
end
