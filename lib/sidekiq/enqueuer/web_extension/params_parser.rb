module Sidekiq
  module Enqueuer
    module WebExtension
      class ParamsParser
        class NoProvidedValueForRequiredParam < StandardError; end

        attr_reader :raw_params, :worker

        def initialize(params, worker)
          @raw_params = params
          @worker = worker
        end

        def process
          worker.params.each do |expected_param|
            value = extract_value(expected_param.name.to_s)
            expected_param.value = value
            raise NoProvidedValueForRequiredParam if expected_param.required? && !expected_param.value.present?
          end
          worker.params.map(&:value)
        end

        private

        def extract_value(param_name)
          return nil unless raw_params[param_name].present?
          cleanup(raw_params[param_name])
        end

        def cleanup(value)
          return nil if value.to_s.downcase == 'nil'
          return '' if value.to_s.strip.empty?
          value
        end
      end
    end
  end
end
