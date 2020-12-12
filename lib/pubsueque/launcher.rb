module Pubsueque
  class Launcher
    def initialize(options)
      @queues = options[:queues]
      @options = options
    end

    def run
      Logger.log 'Starting Pubsueque process...'
      create_topics
      create_subscriptions
      @retry_processor = FailedJobsConsumer.new(@options).tap(&:init)
      subscribers = init_subscribers
      subscribers.each(&:start)

      at_exit do
        Logger.log 'Waiting for jobs to complete processing, would shut down in a moment......'
        subscribers.each { |sub| sub.stop!(10) }
        Logger.log 'Exited!!!!!'
      end
      sleep
    end

    private

    def init_subscribers
      (@queues - ['morgue']).map do |q|
        subscription = Pubsueque.client.subscription "#{q}-subscription"
        subscription.listen(subscription_options) do |message|
          if time = message['at']
            processor = Processor.new(message, @retry_processor, @options)
            Scheduler.schedule(processor, time)
          else
            Processor.process(message, @retry_processor, @options)
          end
        end
      end
    end

    def create_subscriptions
      @queues.map do |name|
        sub = "#{name}-subscription"
        Thread.new do
          begin
            Pubsueque.topics[name].subscribe sub
            Logger.log "Subscription #{sub} successfully created"
          rescue Google::Cloud::AlreadyExistsError
            Logger.log "Subscription #{sub} already exists"
          end
        end
      end.each(&:join)
    end

    def create_topics
      @queues.map do |topic|
        Thread.new do
          begin
            Pubsueque.client.create_topic topic, topic_options
            Logger.log "Topic #{topic} successfully created"
          rescue Google::Cloud::AlreadyExistsError => e
            Logger.log "Topic #{topic} already exists"
          end
        end
      end.each(&:join)
    end

    def subscription_options
      {
        deadline: @options[:deadline],
        threads: { callback: @options[:concurrency] }
      }
    end

    def topic_options
      {
        labels: @options[:labels],
        async: { threads: { publish: @options [:concurrency] } }
      }
    end
  end
end
