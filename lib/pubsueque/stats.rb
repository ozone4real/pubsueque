module Pubsueque
  class Stats
    attr_accessor :jobs_count, :fail_count, :pass_count

    def initialize
      @jobs_count = 0
      @fail_count = 0
      @pass_count = 0

      @semaphore = Mutex.new
    end

    # stats = Stats.new
    # stats.incr(:jobs_count)
    def incr(counter)
      @semaphore.synchronize do
        send("#{counter}=", send(counter) + 1)
      end
    end

    # stats = Stats.new
    # stats.decr(:jobs_count)
    def decr(counter)
      @semaphore.synchronize do
        send("#{counter}=", send(counter) - 1)
      end
    end
  end
end