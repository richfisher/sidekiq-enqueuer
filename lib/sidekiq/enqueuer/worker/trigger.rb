# frozen_string_literal: true

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
          case
          when sidekiq_job?
            Sidekiq::Client.enqueue_to(queue, job, *args_with_values)
          when active_job?
            job.perform_later(*args_with_values)
          else
            raise UnsupportedJobType, "Unsupported job type: #{job}"
          end
        end

        def enqueue_in(time_in_seconds)
          case
          when sidekiq_job?
            Sidekiq::Client.enqueue_to_in(queue, time_in_seconds, job, *args_with_values)
          when active_job?
            job.set(wait: time_in_seconds).perform_later(*args_with_values)
          else
            raise UnsupportedJobType, "Unsupported job type: #{job}"
          end
        end

        private

        def deduce_queue
          job.respond_to?(:sidekiq_options) ? job.sidekiq_options["queue"].to_s : "default"
        end

        def sidekiq_job?
          Sidekiq::Enqueuer::Utils.sidekiq_job?(job)
        end

        def active_job?
          Sidekiq::Enqueuer::Utils.active_job?(job)
        end
      end
    end
  end
end
