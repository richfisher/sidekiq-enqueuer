# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "sidekiq/enqueuer/version"

Gem::Specification.new do |spec|
  spec.name = "sidekiq-enqueuer"
  spec.version = Sidekiq::Enqueuer::VERSION
  spec.required_ruby_version = ">= 2.4"

  spec.authors = %w[richfisher basherru]
  spec.email = %w[richfisher.pan@gmail.com dr.bazhenoff2017@yandex.ru]
  spec.homepage = "https://github.com/basherru/sidekiq-enqueuer"
  spec.licenses = ["MIT"]

  spec.summary = <<-SUMMARY
    A Sidekiq Web extension to enqueue/schedule jobs with custom perform params in Web UI.
  SUMMARY
  spec.description = <<-DESCRIPTION
    A Sidekiq Web extension to enqueue/schedule jobs with custom perform params in Web UI.
    Support both Sidekiq::Worker and ActiveJob.
  DESCRIPTION

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "coveralls_reborn"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rails", "> 4.2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop-config-umbrellio"
  spec.add_development_dependency "sidekiq"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "timecop"
end
