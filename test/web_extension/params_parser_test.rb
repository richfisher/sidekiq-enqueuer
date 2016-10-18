require 'test_helper'

module Sidekiq
  module Enqueuer
    module WebExtension
      describe ParamsParser do
        include Rack::Test::Methods

        describe '#initializer' do
          let(:parser) { Sidekiq::Enqueuer::WebExtension::ParamsParser.new('userId' => 'value') }

          it 'expects a correct name assignment' do
            assert_instance_of Hash, parser.raw_params
            assert_equal ['userId'], parser.raw_params.keys
            assert_equal ['value'], parser.raw_params.values
          end
        end

        describe '#process' do
          let(:parser) { Sidekiq::Enqueuer::WebExtension::ParamsParser.new(params) }

          describe 'having only string parameters' do
            let(:params) do
              { 'user_id' => 'valueParamUserId', 'optional_param' => 'valueTesting' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal %w(valueParamUserId valueTesting), parser.process
            end
          end

          describe 'having the first parameter as a Hash and a second as string' do
            let(:params) do
              { 'user_id' => '{ param1: value1, param2: value2 }', 'optional_param' => 'valueTesting' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal %w(value1 value2 valueTesting), parser.process
            end
          end

          describe 'having the first parameter as String and the second as Hash' do
            let(:params) do
              { 'optional_param' => 'valueTesting', 'user_id' => '{ param1: value1, param2: value2 }' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal %w(value1 value2 valueTesting), parser.process
            end
          end

          describe 'having both params as Hash' do
            let(:params) do
              { 'user_id' => '{ param1: value1, param2: value2 }',
                'optional_param' => '{ param3: value3, param4: value4 }' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal %w(value1 value2 value3 value4), parser.process
            end
          end

          describe 'having empty values' do
            let(:params) do
              { 'user_id' => 'testing', 'optional_param' => '' }
            end

            it 'parses params to return an array of values' do
              assert_instance_of Array, parser.process
              assert_equal ['testing'], parser.process
            end
          end
        end
      end
    end
  end
end
