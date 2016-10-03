require 'test_helper'

module Sidekiq
  module Enqueuer
    module WebExtension
      describe Helper do
        include Rack::Test::Methods

        class TestHelperClass
          include Sidekiq::Enqueuer::WebExtension::Helper

          def params
            { 'post' => { 'user_id' => '{ param1: value1, param2: value2 }',
                          'optional_param' => 'testing' } }
          end
        end

        let(:helper) { TestHelperClass.new }

        describe '.get_params_by_action' do
          describe 'having valid params for the required action' do
            it 'returns a list of values passed as parameters' do
              assert_equal %w(value1 value2 testing), helper.get_params_by_action('post')
            end
          end

          describe 'providing invalid action params' do
            it 'returns a list of values passed as parameters' do
              assert_empty helper.get_params_by_action('none')
            end
          end
        end

        describe '.find_job_by_class_name' do
          before do
            Sidekiq::Enqueuer.configure do |config|
              config.jobs = [NoParamWorker, HardWorker]
            end
          end

          describe 'providing a valid job name' do
            it 'returns the single instance of the Job to use' do
              assert_instance_of Sidekiq::Enqueuer::Worker::Instance, helper.find_job_by_class_name('HardWorker')
              assert_equal 'HardWorker', helper.find_job_by_class_name('HardWorker').name
            end
          end

          # describe 'providing a valid job' do
          #   it 'returns the single instance of the Job to use' do
          #     assert_instance_of Sidekiq::Enqueuer::Worker::Instance, helper.find_job_by_class_name(HardWorker)
          #     assert_equal 'HardWorker', helper.find_job_by_class_name(HardWorker).name
          #   end
          # end

          describe 'providing an invalid job name' do
            it 'returns the single instance of the Job to use' do
              assert_nil helper.find_job_by_class_name('TestingWorker')
            end
          end
        end
      end
    end
  end
end
