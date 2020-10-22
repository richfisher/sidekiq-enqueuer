# frozen_string_literal: true

module Sidekiq
  module Enqueuer
    class Configuration
      class UnsupportedJobType < StandardError; end

      attr_accessor :jobs, :async

      IGNORED_CLASSES = %w[Sidekiq::Extensions
                           Sidekiq::Extensions::DelayedModel
                           Sidekiq::Extensions::DelayedMailer
                           Sidekiq::Extensions::DelayedClass
                           ActiveJob::QueueAdapters].freeze

      def initialize(async: true)
        @async = async
      end

      def available_jobs
        sort(provided_or_default_jobs)
      end

      private

      def provided_or_default_jobs
        return application_jobs if jobs.nil?

        jobs.map { |job| constantize_if_needed(job) }
      end

      def constantize_if_needed(job)
        case job
        when Class
          job
        when String, Symbol
          Object.const_get(job)
        else
          raise UnsupportedJobType, "Unsupported job type: #{job}"
        end
      end

      def sort(jobs)
        jobs.sort_by(&:name)
      end

      # Loads all jobs within the application after an eager_load
      # Filters Sidekiq system Jobs
      def application_jobs
        rails_eager_load!
        jobs = [*sidekiq_jobs, *active_jobs].flatten
        jobs.reject { |klass| IGNORED_CLASSES.include?(klass.to_s) }
      end

      def sidekiq_jobs
        ObjectSpace.each_object(Class).select { |job| Sidekiq::Enqueuer::Utils.sidekiq_job?(job) }
      end

      def active_jobs
        ObjectSpace.each_object(Class).select { |job| Sidekiq::Enqueuer::Utils.active_job?(job) }
      end

      # Load all classes from the included application before selecting Jobs from it
      def rails_eager_load!
        return unless defined?(::Rails)
        return unless ::Rails.respond_to?(:env)
        return if ::Rails.env.production?

        ::Rails.application.eager_load!
      end
    end
  end
end
