require 'test_helper'

module Sidekiq
  module Enqueuer
    module WebExtension
      describe ParamsParser do
        include Rack::Test::Methods
        let(:worker) { Sidekiq::Enqueuer::Worker::Instance.new(WorkerWithOptionalParams, false) }

        describe '#initializer' do
          let(:parser) { Sidekiq::Enqueuer::WebExtension::ParamsParser.new(params, worker) }
          let(:params) do
            { 'userId' => 'value' }
          end
          it 'expects a correct name assignment' do
            assert_instance_of Hash, parser.raw_params
            assert_equal ['userId'], parser.raw_params.keys
            assert_equal ['value'], parser.raw_params.values
          end
        end

        describe '#process' do
          let(:parser) { Sidekiq::Enqueuer::WebExtension::ParamsParser.new(params, worker) }

          describe 'having only string parameters' do
            let(:params) do
              { 'required_param' => 'valueParamUserId', 'optional_param' => 'valueTesting' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal ['valueParamUserId', 'valueTesting', nil], parser.process
            end
          end

          describe 'having the first parameter as a Hash and a second as string' do
            let(:params) do
              { 'required_param' => 'value1', 'optional_param' => 'valueTesting' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal ['value1', 'valueTesting', nil], parser.process
            end
          end

          describe 'having empty values' do
            let(:params) do
              { 'required_param' => 'testing', 'optional_param' => '' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal ['testing', nil, nil], parser.process
            end
          end

          describe 'having no value for required fields' do
            let(:params) do
              { 'required_param' => '', 'optional_param' => '' }
            end

            it 'parses params and raises an error' do
              assert_raises(Sidekiq::Enqueuer::WebExtension::ParamsParser::NoProvidedValueForRequiredParam) do
                parser.process
              end
            end
          end
        end
      end
    end
  end
end
