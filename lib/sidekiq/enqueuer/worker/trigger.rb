module Sidekiq
  module Enqueuer
    module Worker
      class Trigger
        class UnsupportedJobType < StandardError; end

        attr_reader :job, :queue, :args_with_values

        def initialize(job, input_param_hash)
          @job = job
          @queue = deduce_queue
          @args_with_values = input_param_hash
        end

        def enqueue
          if sidekiq_job?
            Sidekiq::Client.enqueue_to(queue, job, *args_with_values)
          elsif active_job?
            return job.perform_later(*args_with_values)
          else
            raise UnsupportedJobType
          end
        end

        def enqueue_in(time_in_seconds)
          if sidekiq_job?
            Sidekiq::Client.enqueue_to_in(queue, time_in_seconds, job, *args_with_values)
          elsif active_job?
            job.set(wait: time_in_seconds).perform_later(*args_with_values)
          else
            raise UnsupportedJobType
          end
        end

        private

        def deduce_queue
          job.respond_to?(:sidekiq_options) ? job.sidekiq_options['queue'].to_s : 'default'
        end

        def sidekiq_job?
          job.included_modules.include? ::Sidekiq::Worker
        end

        def active_job?
          job <= ::ActiveJob::Base
        end
      end
    end
  end
end
