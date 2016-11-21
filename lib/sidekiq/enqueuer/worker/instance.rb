module Sidekiq
  module Enqueuer
    module Worker
      class Instance
        attr_reader :job, :instance_method, :params, :enqueue_using_async

        def initialize(job, enqueue_using_async)
          @job = job
          @enqueue_using_async = enqueue_using_async
          @instance_method     = deduce_instance_method
          @params              = deduce_params
        end

        def trigger(input_params)
          trigger_job(input_params).enqueue
        end

        def trigger_in(seconds, input_params)
          trigger_job(input_params).enqueue_in(seconds.to_s.to_i.seconds)
        end

        def name
          @job.name
        end

        private

        def trigger_job(input_params)
          Sidekiq::Enqueuer::Worker::Trigger.new(job, input_params)
        end

        # TODO: what if two of this methods exist? which one to pick to figure out params?
        def deduce_instance_method
          [:perform, :perform_in, :perform_async, :perform_at].each do |evaluating_method|
            return evaluating_method if job.instance_methods.include?(evaluating_method)
          end
          nil
        end

        def deduce_params
          worker_params.empty? ? [] : worker_params.map { |e| Sidekiq::Enqueuer::Worker::Param.new(e[1], e[0]) }
        end

        def worker_params
          job.instance_method(instance_method).parameters
        end
      end
    end
  end
end
