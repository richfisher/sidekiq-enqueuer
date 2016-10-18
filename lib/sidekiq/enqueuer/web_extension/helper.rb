module Sidekiq
  module Enqueuer
    module WebExtension
      module Helper
        def get_params_by_action(name)
          return [] if params[name].nil?
          ParamsParser.new(params[name]).process
        end

        def find_job_by_class_name(job_class_name)
          Sidekiq::Enqueuer.all_jobs.find do |job_klass|
            job_klass.job == job_class_name || job_klass.job.to_s == job_class_name || job_klass.name == job_class_name
          end
        end

        # TODO: Figure out the need of unlock!
        # def does_job_have_unlock_method(klass_or_module)
        #   klass_or_module.respond_to?(:unlock!)
        #   false
        # end

        # TODO: Figure out the need of unlock!
        # def get_job_unlock_params(klass_or_module)
        #   klass_or_module.method(:unlock!).parameters.map{ |e| e[1]}
        # end

        # TODO: Figure out the need of unlock!
        # def self.unlock!(klass, values)
        #   parsed_values = values_parser(values)
        #   klass.unlock!(*parsed_values)
        # end
      end
    end
  end
end
