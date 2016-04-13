# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/enqueuer/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-enqueuer"
  spec.version       = Sidekiq::Enqueuer::VERSION
  spec.authors       = ["richfisher"]
  spec.email         = ["richfisher.pan@gmail.com"]

  spec.summary       = %q{A Sidekiq Web extension to enqueue/schedule job in Web UI.}
  spec.description   = %q{A Sidekiq Web extension to enqueue/schedule job in Web UI. Support both Sidekiq::Worker and ActiveJob.}
  spec.homepage      = "https://github.com/richfisher/sidekiq-enqueuer"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "sidekiq"
  spec.add_development_dependency "rails", '> 4.2'
  spec.add_development_dependency "sinatra"
end
