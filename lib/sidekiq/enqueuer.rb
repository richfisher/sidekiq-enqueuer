require 'sidekiq/web'
require 'sidekiq/enqueuer/version'
require 'sidekiq/enqueuer/configuration'
require 'sidekiq/enqueuer/worker/instance'
require 'sidekiq/enqueuer/worker/param'
require 'sidekiq/enqueuer/worker/trigger'
require 'sidekiq/enqueuer/web_extension/loader'
require 'sidekiq/enqueuer/web_extension/helper'
require 'sidekiq/enqueuer/web_extension/params_parser'
require 'sidekiq/enqueuer/railtie' if defined? ::Rails::Railtie

module Sidekiq
  module Enqueuer
    class << self
      attr_accessor :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def all_jobs
        included_jobs = defined?(@all_jobs) ? @all_jobs : configuration.all_jobs
        included_jobs.each_with_object([]) do |job_klass, acc|
          acc << Worker::Instance.new(job_klass, configuration.enqueue_using_async)
        end
      end
    end
  end
end

if defined?(Sidekiq::Web)
  Sidekiq::Web.register Sidekiq::Enqueuer::WebExtension::Loader
  Sidekiq::Web.tabs['Enqueuer'] = 'enqueuer'
  Sidekiq::Web.settings.locales << File.join(File.dirname(__FILE__), 'enqueuer/locales')
end
