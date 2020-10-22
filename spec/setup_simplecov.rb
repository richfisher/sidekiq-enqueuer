# frozen_string_literal: true

require "simplecov"
require "coveralls"

SimpleCov.configure do
  enable_coverage :line
  enable_coverage :branch

  minimum_coverage line: 94, branch: 65

  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ])

  add_group "Worker", "/lib/enqueuer/worker"
  add_group "WebExtension", "/lib/enqueuer/web_extension"

  add_filter "/lib/sidekiq/enqueuer/views/"
  add_filter "/lib/sidekiq/enqueuer/locales/"
  add_filter "/spec/"
end
