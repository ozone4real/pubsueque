require_relative 'lib/pubsueque/version'

Gem::Specification.new do |spec|
  spec.name          = 'pubsueque'
  spec.version       = Pubsueque::VERSION
  spec.authors       = ['ozone4real']
  spec.email         = ['ezenwaogbonna1@gmail.com']

  spec.summary       = 'ActiveJob compatible job queuing library based on Google pub/sub'
  spec.description   = 'Think Sidekiq/Resque/Delayed but with a Google Pub/Sub backend instead of Redis/MemCached.'
  spec.homepage      = 'https://github.com/ozone4real/pubsueque.git'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ozone4real/pubsueque.git'
  spec.metadata['changelog_uri'] = 'https://github.com/ozone4real/pubsueque.git'

  spec.add_dependency 'google-cloud-pubsub'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
