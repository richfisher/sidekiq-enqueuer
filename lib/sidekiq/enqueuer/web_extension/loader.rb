# frozen_string_literal: true

module Sidekiq
  module Enqueuer
    module WebExtension
      module Loader
        # rubocop:disable Metrics/MethodLength
        def self.registered(app)
          app.helpers(WebExtension::Helper)

          view_path = File.join(File.expand_path("..", __dir__), "views")

          app.get "/enqueuer" do
            @jobs = Sidekiq::Enqueuer.jobs

            render(:erb, File.read(File.join(view_path, "index.erb")))
          end

          app.get "/enqueuer/:job_class_name" do
            @job = find_job_by_class_name(params[:job_class_name])

            render(:erb, File.read(File.join(view_path, "new.erb")))
          end

          app.post "/enqueuer" do
            job = find_job_by_class_name(params[:job_class_name])

            if job.present?
              requested_params = get_params_by_action("perform", job)

              case params["submit"]
              when "Enqueue"
                job.trigger(requested_params)
              when "Schedule"
                job.trigger_in(params["enqueue_in"], requested_params)
              end
            end

            redirect "/enqueuer"
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
