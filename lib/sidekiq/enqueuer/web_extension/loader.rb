module Sidekiq
  module Enqueuer
    module WebExtension
      module Loader
        def self.registered(app)
          view_path = File.join(File.expand_path('../..', __FILE__), 'views')
          app.helpers WebExtension::Helper

          app.get '/enqueuer' do
            @jobs = Sidekiq::Enqueuer.all_jobs
            render(:erb, File.read(File.join(view_path, 'index.erb')))
          end

          app.get '/enqueuer/:job_class_name' do
            @job = find_job_by_class_name(params[:job_class_name])
            render(:erb, File.read(File.join(view_path, 'new.erb')))
          end

          app.post '/enqueuer' do
            job = find_job_by_class_name(params[:job_class_name])

            if job
              requested_params = get_params_by_action('perform', job)
              job.trigger(requested_params) if params['submit'] == 'Enqueue'
              job.trigger_in(params['enqueue_in'], requested_params) if params['submit'] == 'Schedule'
            end
            redirect "#{root_path}enqueuer"
          end
        end
      end
    end
  end
end
