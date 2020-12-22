module ActiveJob
  module QueueAdapters
    class PubsuequeAdapter
      def enqueue(job)
        # if `class` ever becomes an argument in the output of `job.serialize`
        # we may have a problem
        # https://api.rubyonrails.org/classes/ActiveJob/Core.html#method-i-serialize
        # since this library is not dependent on ActiveJob, we don't know what
        # the output of serialize is – it doesn't have to be a dictionary
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
