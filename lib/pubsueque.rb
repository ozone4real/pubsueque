require 'google/cloud/pubsub'
require 'pubsueque/version'
require 'pubsueque/launcher'
require 'pubsueque/logger'
require 'pubsueque/processor'
require 'pubsueque/worker'
require 'pubsueque/publisher'
require 'pubsueque/failed_jobs_consumer'
require 'pubsueque/stats'
require 'pubsueque/scheduler'

module Pubsueque
  DEFAULT_WORKER_OPTIONS = {
    retries: 2, # failed jobs should be retried twice as mentioned in the requirements
    queue_name: 'default'
  }.freeze

  DEFAULT_OPTIONS = {
    concurrency: 4,
    labels: {},
    queues: %w[default morgue],
    deadline: 20,
    retry_interval: 300 # failed jobs should be retried 5 minutes apart as mentioned in the requirements
  }.freeze

  private_constant :DEFAULT_OPTIONS

  DEFAULT_OPTIONS.keys.each do |k|
    define_singleton_method("#{k}=") do |value|
      options[k] = value
    end
  end

  class << self
    def client
      @client ||= Google::Cloud::Pubsub.new(project_id: "okrrr")
    end

    def topics
      @topics ||= request_topics
    end

    def request_topics
      options[:queues].each_with_object({}) do |topic, obj|
        obj[topic] = Thread.new do
          client.topic topic
        end
      end.transform_values(&:value)
    end

    def options
      @options ||= DEFAULT_OPTIONS.dup
    end

    # Enables configuration in a config initializer file (config/initializers/pubsueque.rb in Rails).
    # You would be able to configure the pubsueque server and overwrite defaults like this:
    #   Pubsueque.configure do |config|
    #     config.concurrency = 10
    #     config.deadline = 20
    #     config.queues = [:default]
    #   end
    def configure
      yield self
    end

    # See line 89 -90
    def reloader
      @reloader ||= proc { |&blk| blk.call }
    end

    def reloader=(reloader)
      raise ArgumentError, "reloader must respond to 'call'" unless reloader.respond_to? :call

      @reloader = reloader
    end
  end
end

# There are probably better ways to determine if the current directory is a Rails
# root directory but this is what I could think of
def rails?
  File.exist?('./bin/rails')
end

if rails?
  require 'active_job/queue_adapters/pubsueque_adapter.rb'
  module Pubsueque
    # Inspired by Sidekiq. Making the pubsueque worker accessors available to AJ classes
    class Rails < ::Rails::Engine
      initializer('pubsubeque.active_job_integration') do
        ActiveSupport.on_load(:active_job) do
          include ::Pubsueque::Worker::Options unless respond_to?(:pubsueque_worker_options)
        end
      end

      # Inspired by Sidekiq. From Rails 5, Rails application code should be wrapped in a reloader
      # to trigger autoloading.
      class Reloader
        def initialize(app = ::Rails.application)
          @app = app
        end

        def call
          @app.reloader.wrap do
            yield
          end
        end

        def inspect
          "#<Pubsueque::Rails::Reloader @app=#{@app.class.name}>"
        end
      end

      config.after_initialize do
        Pubsueque.reloader = Pubsueque::Rails::Reloader.new
      end
    end
  end
end
