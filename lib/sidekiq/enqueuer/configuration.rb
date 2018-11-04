module Sidekiq
  module Enqueuer
    class Configuration
      attr_accessor :jobs, :enqueue_using_async

      IGNORED_CLASSES = %w(Sidekiq::Extensions
                           Sidekiq::Extensions::DelayedModel
                           Sidekiq::Extensions::DelayedMailer
                           Sidekiq::Extensions::DelayedClass
                           ActiveJob::QueueAdapters).freeze

      def initialize(enqueue_using_async = nil)
        @enqueue_using_async = true if enqueue_using_async.nil?
      end

      def all_jobs
        @jobs = defined?(@jobs) ? sort(@jobs) : sort(application_jobs)
      end

      private

      def sort(all_jobs)
        all_jobs.sort_by(&:name)
      end

      # Loads all jobs within the application after an eager_load
      # Filters Sidekiq system Jobs
      def application_jobs
        rails_eager_load
        all_jobs = []
        all_jobs << sidekiq_jobs
        all_jobs << active_jobs if defined?(::ActiveJob)
        all_jobs = all_jobs.flatten
        all_jobs.delete_if { |klass| IGNORED_CLASSES.include?(klass.to_s) }
      end

      def sidekiq_jobs
        ObjectSpace.each_object(Class).select { |k| k.included_modules.include?(::Sidekiq::Worker) }
      end

      def active_jobs
        ObjectSpace.each_object(Class).select { |k| k.superclass == ::ActiveJob::Base }
      end

      # Load all classes from the included application before selecting Jobs from it
      def rails_eager_load
        ::Rails.application.eager_load! if defined?(::Rails) && ::Rails.respond_to?(:env) && !::Rails.env.production?
      end
    end
  end
end
