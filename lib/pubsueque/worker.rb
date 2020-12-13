module Pubsueque
  module Worker
    def self.included(base)
      base.include(Options)
      base.extend(ClassMethods)
      base.singleton_class.class_eval do
        attr_reader :pubsueque_worker_options
      end
    end

    module ClassMethods
      def execute(*args)
        Publisher.publish(
          DEFAULT_WORKER_OPTIONS.merge(
            'job_class' => to_s, 'class' => to_s, 'arguments' => args
          )
        )
      end

      def execute_at(time, *args)
        Publisher.publish(
          DEFAULT_WORKER_OPTIONS.merge(
            'job_class' => to_s, 'class' => to_s, 'arguments' => args, 'at' => time
          )
        )
      end
    end

    module Options
      def self.included(base)
        base.extend(ClassMethods)
        base.singleton_class.class_eval do
          attr_reader :pubsueque_worker_options
        end
      end

      module ClassMethods
        def pubsueque_options(**options)
          @pubsueque_worker_options = DEFAULT_WORKER_OPTIONS.merge(options)
        end
      end
    end
  end
end
