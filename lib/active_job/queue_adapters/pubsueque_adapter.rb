module ActiveJob
  module QueueAdapters
    class PubsuequeAdapter
      def enqueue(job)
        args = job.serialize.merge('class' => JobWrapper.to_s)
        Pubsueque::Publisher.publish args
      end

      def enqueue_at(job, timestamp)
        args = job.serialize.merge('class' => JobWrapper.to_s, 'at' => timestamp)
        Pubsueque::Publisher.publish args
      end
    end

    class JobWrapper
      include Pubsueque::Worker
      def perform(job_data)
        Base.execute job_data
      end
    end
  end
end

