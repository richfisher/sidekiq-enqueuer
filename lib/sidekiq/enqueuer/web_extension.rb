module Sidekiq::Enqueuer::WebExtension
  def self.registered(app)
    view_path = File.join(File.expand_path("..", __FILE__), "views")

    app.helpers do
      def get_job_perform_params(klass_or_module)
        klass_or_module.instance_method(:perform).parameters.map{ |e| e[1]}
      end

      def does_job_have_unlock_method(klass_or_module)
        klass_or_module.respond_to?(:unlock!)
      end

      def get_job_unlock_params(klass_or_module)
        klass_or_module.method(:unlock!).parameters.map{ |e| e[1]}
      end

      def get_params_by_name(name)
        params[name].nil? ? [] : params[name].values
      end
    end

    app.get "/enqueuer" do
      @jobs = Sidekiq::Enqueuer.get_jobs

      render(:erb, File.read(File.join(view_path, "index.erb")))
    end

    app.get "/enqueuer/:job_class_name" do
      @klass = params[:job_class_name].constantize
      render(:erb, File.read(File.join(view_path, "new.erb")))
    end

    app.post "/enqueuer" do
      klass = params[:job_class_name].constantize

      if params['unlock-enable'] && params['unlock-enable'] != ''
        Sidekiq::Enqueuer.unlock!(klass, get_params_by_name('unlock'))
      end

      if params['submit'] == 'Enqueue'
        Sidekiq::Enqueuer.perform_async(klass, get_params_by_name('perform'))
      end

      if params['submit'] == 'Schedule'
        Sidekiq::Enqueuer.perform_in(klass, params['enqueue_in'], get_params_by_name('perform'))
      end

      redirect "#{root_path}enqueuer"
    end

  end
end
