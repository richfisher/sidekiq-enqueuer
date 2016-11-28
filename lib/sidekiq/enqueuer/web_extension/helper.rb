module Sidekiq
  module Enqueuer
    module WebExtension
      module Helper
        def get_params_by_action(name, job)
          return [] if params[name].nil?
          Sidekiq::Enqueuer::WebExtension::ParamsParser.new(params[name], job).process
        end

        def find_job_by_class_name(job_class_name)
          Sidekiq::Enqueuer.all_jobs.find do |job_klass|
            job_klass.job == job_class_name || job_klass.job.to_s == job_class_name || job_klass.name == job_class_name
          end
        end
      end
    end
  end
end
