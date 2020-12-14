# Pubsueque

ActiveJob (Rails) compatible job queuing library that enqueues jobs to Google Pub/Sub and executes them immediately or at a specified time. Think Sidekiq/Resque/Delayed but with a Google Pub/Sub backend.

## Requirement
Ruby >=2.5

## Installation
This can be installed as a gem via this Github repo path. Add this line to your application's Gemfile:

```ruby
gem 'pubsueque', github: 'ozone4real/pubsueque'
```

And then execute:

    $ bundle install

Or install it yourself using the `specific_install` gem:

    $ gem install specific_install
    $ gem specific_install https://github.com/ozone4real/pubsueque.git

## Usage

## Pubsueque Server

To boot up the background jobs server, you first need to export your google cloud configuration file to your environment:

```
    $ export GOOGLE_APPLICATION_CREDENTIALS=/path/to/config/file
```
Note: The Google cloud entity(service account, user, e.t.c) in the config must have top-level permissions for google pub/sub (owner or admin). He/She/It should be able to read/delete/create Pub/Sub resources). 

Run the pubsueque executable to boot-up the server:

```
    $ pubsueque
```
It needs a config/environment.rb file to be present relative to the working directory. The file should contain your loaded application. This is default in a Rails application

## ActiveJob

Configure ActiveJob to use the pubsueque queue adapter as its adapter. In your Rails configuration file:

```ruby
    config.active_job.queue_adapter = :pubsueque
```
With that ActiveJob would use the pubsueque adapter to enqueue jobs to Google pub/sub and execute them immediately or at a specified time.

```ruby
    class StupidJob < ActiveJob::Base
        def perform(args)
            // job
        end
    end
    
    StupidJob.perform_later(args) # enqueue the job to pub/sub and execute in the background immediately (after the pub/sub subscriber receives the job).
    StupidJob.set(wait_until: 10.minutes).perform_later(args) # enqueue the job to pub/sub and execute in 10 minutes.
```

## Without ActiveJob/Rails

```ruby
    class StupidJob
        include Pubsueque::Worker
        
        def perform(*args)
            # job
        end
    end
    
    StupidJob.enqueue(args) # enqueue the job to pub/sub and execute in the background immediately
    StupidJob.enqueue_at(10.mins, args) # enqueue the job to pub/sub and execute in 10 minutes.
```

## Job level configurations

You can use active job's configuration methods to set options for a specific job. Alternatively, you can use the `pubsueque_options` writer to set options for the job. This would merge with/override jobs set with ActiveJob methods.


```ruby
    class StupidJob < ActiveJob::Base
        pusbsueque_options queue_name: :mailers, retries: 4
        
        def perform(*args)
            // job
        end
    end
```

Default options: 
```ruby
    {
        queue_name: :default # represents a pub/sub topic in which the specific job would be published to.
        retries: 2 # based on the requirement
    }
```

## Server configurations
Default options:

```ruby
{
    concurrency: 4 # number of threads that each pub/sub subscription would listen for and process received messages(jobs). If your jobs contain database queries, it is best to keep this not-too-high, so as to work well with ActiveRecord's connection pool (which has a default size of 5).
    labels: {} # pub/sub labels,
    queues: %w[default morgue], # represents pub/sub topics in which jobs would be published to. They would be created when the server is booted (if they don't exist)
    deadline: 20, # Google pub/sub ack deadline
    retry_interval: 300 # failed jobs should be retried 5 minutes apart as mentioned in the requirements
  }
```

You can configure/overwrite these defaults by setting up a pubsueque config file as an initializer like: `config/initializer/pubsueque.rb`. In the file you can do:

```ruby
    Pubsueque.configure do |config|
        config.concurrency = 2
        config.queues = %w[default morgue]
        config.deadline = 10
        config.retry_interval = 300
    end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pubsueque.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
