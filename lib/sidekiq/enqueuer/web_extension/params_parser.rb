module Sidekiq
  module Enqueuer
    module WebExtension
      class ParamsParser
        attr_reader :raw_params

        def initialize(params)
          @raw_params = params
        end

        def process
          all_params    = filter_empty(raw_params)
          hash_params   = yaml_to_params(all_params.values)
          all_params    = hash_params.merge!(all_params) if hash_params
          simple_params = filter_complex(all_params)
          simple_params.values.compact.flatten
        end

        private

        def yaml_to_params(values)
          unique_params = {}
          values.each do |str_param|
            param_hash = expected_hash?(str_param) ? convert_to_ruby(str_param) : {}
            unique_params.merge!(param_hash)
          end
          unique_params
        end

        def filter_empty(given_params)
          given_params.delete_if { |_, v| v.to_s.empty? }
        end

        def filter_complex(given_params)
          given_params.delete_if { |_, v| expected_hash?(v.to_s) }
        end

        def convert_to_ruby(value)
          YAML.parse(value.to_s.strip).to_ruby
        end

        def expected_hash?(value)
          value.to_s.start_with?('{') && value.to_s.end_with?('}')
        end
      end
    end
  end
end
