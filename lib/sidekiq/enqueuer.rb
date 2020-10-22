# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/enqueuer/configuration"
require "sidekiq/enqueuer/utils"
require "sidekiq/enqueuer/version"
require "sidekiq/enqueuer/worker/instance"
require "sidekiq/enqueuer/worker/param"
require "sidekiq/enqueuer/worker/trigger"
require "sidekiq/enqueuer/web_extension/helper"
require "sidekiq/enqueuer/web_extension/loader"
require "sidekiq/enqueuer/web_extension/params_parser"

module Sidekiq
  module Enqueuer
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def jobs
        configuration.available_jobs.map do |job|
          Worker::Instance.new(job, async: configuration.async)
        end
      end
    end
  end
end

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::Enqueuer::WebExtension::Loader
  Sidekiq::Web.tabs["Enqueuer"] = "enqueuer"
  Sidekiq::Web.settings.locales << File.join(File.dirname(__FILE__), "enqueuer/locales")
end
