require 'sidekiq/web'
require "sidekiq/enqueuer/version"
require 'sidekiq/enqueuer/web_extension'
require 'sidekiq/enqueuer/railtie' if defined? ::Rails::Railtie

module Sidekiq
  module Enqueuer
    def self.rails_eager_load
      if defined?(::Rails) && ::Rails.env != 'production'
        ::Rails.application.eager_load! 
      end
    end

    def self.get_job_modules
      ObjectSpace.each_object(Module).select { |klass| has_worker_module?(klass) }
                                     .delete_if {|klass| klass.to_s =~ /^Sidekiq::Extensions/}
                                     .delete_if {|klass| klass.to_s =~ /^ActiveJob::QueueAdapters/}
    end

    def self.get_job_classes
      ObjectSpace.each_object(Class).select { |klass| is_job_class?(klass) }
    end

    def self.get_jobs
      return @jobs if @jobs

      rails_eager_load
      jobs = get_job_modules + get_job_classes
      @jobs = jobs.map(&:to_s).uniq.map(&:constantize)
    end

    def self.is_job_class?(klass)
      return false if !defined?(::ActiveJob)

      klass < ::ActiveJob::Base
    end

    def self.has_worker_module?(klass)
      klass.included_modules.include? ::Sidekiq::Worker
    end

    def self.perform_async(klass, values)
      parsed_values = values_parser(values)
      if is_job_class?(klass)
        klass.perform_later(*parsed_values)
      elsif has_worker_module?(klass)
        klass.perform_async(*parsed_values)
      end
    end

    def self.perform_in(klass, seconds_str, values)
      parsed_values = values_parser(values)
      seconds = seconds_str.to_i.seconds
      if is_job_class?(klass)
        klass.set(wait: seconds).perform_later(*parsed_values)
      elsif has_worker_module?(klass)
        klass.perform_in(seconds, *parsed_values)
      end
    end

    def self.unlock!(klass, values)
      parsed_values = values_parser(values)
      klass.unlock!(*parsed_values)
    end

    def self.values_parser(values)
      parsed_values = []
      errors = []
      for value in values.map(&:strip)
        if value =~ /^{/
          parsed_values << YAML.load(value) rescue errors << value
        else
          parsed_values << value
        end
      end
      raise errors if errors.size > 0
      parsed_values
    end

  end
end

Sidekiq::Web.register Sidekiq::Enqueuer::WebExtension
Sidekiq::Web.tabs["Enqueuer"] = "enqueuer"
Sidekiq::Web.settings.locales << File.join(File.dirname(__FILE__), "enqueuer/locales")