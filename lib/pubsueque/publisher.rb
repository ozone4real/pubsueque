module Pubsueque
  class Publisher
    def initialize(options)
      prepare_attributes(options)
    end

    def publish
      @topic.publish_async('Enqueue job', @options) do |result|
        if result.succeeded?
          @job_id = result.message_id
          Logger.log "Successfully published message #{result.message_id} with params: #{result.attributes} at #{Time.now}"
        else
          Logger.log "Error: Failed to publish the message #{result.message_id} with params: #{result.attributes}"
        end
      end

      at_exit do
        @topic.async_publisher.stop!(10)
      end
      @job_id
    end

    def self.publish(options)
      new(options).publish
    end

    private

    def prepare_attributes(options)
      Pubsueque.reloader.call do
        concrete_opts = Object.const_get(options['job_class']).pubsueque_worker_options || {}
        base_opts = Object.const_get(options['class']).pubsueque_worker_options || {}
        @worker_options = base_opts.merge concrete_opts
      end

      @options = options.merge(@worker_options).transform_keys(&:to_s)
      @topic = if @options.delete('morgue')
                 Pubsueque.topics['morgue']
               else
                 Pubsueque.topics[@options['queue_name'].to_s]
               end
    end
  end
end
