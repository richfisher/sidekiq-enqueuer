require 'test_helper'

module Sidekiq
  module Enqueuer
    module Worker
      describe Instance do
        include Rack::Test::Methods

        describe '#initializer' do
          describe 'having perform with parameters' do
            let(:instance) { Sidekiq::Enqueuer::Worker::Instance.new(HardWorker, false) }

            it 'expects to have a defined perform_method ' do
              assert_equal :perform, instance.instance_method
            end

            it 'expects to have a defined enqueue_using_async ' do
              assert_equal false, instance.enqueue_using_async
            end

            it 'expects to deduce perform method params correctly' do
              assert 2, instance.params.size
              assert_instance_of Sidekiq::Enqueuer::Worker::Param, instance.params.first
              assert_instance_of Sidekiq::Enqueuer::Worker::Param, instance.params.last
            end
          end

          describe 'having perform without parameters' do
            let(:instance) { Sidekiq::Enqueuer::Worker::Instance.new(WorkerWithNoParams, false) }

            it 'expects to have a defined perform_method ' do
              assert_equal :perform, instance.instance_method
            end

            it 'expects to have a defined enqueue_using_async ' do
              assert_equal false, instance.enqueue_using_async
            end

            it 'expects to deduce perform method params correctly' do
              assert 0, instance.params.size
            end
          end

          describe 'having a method different than perform' do
            let(:instance) { Sidekiq::Enqueuer::Worker::Instance.new(WorkerWithPerformAsync, false) }

            it 'expects to have a defined perform_method ' do
              assert_equal :perform_async, instance.instance_method
            end

            it 'expects to have a defined enqueue_using_async ' do
              assert_equal false, instance.enqueue_using_async
            end

            it 'expects to deduce perform method params correctly' do
              assert 2, instance.params.size
              assert_instance_of Sidekiq::Enqueuer::Worker::Param, instance.params.first
              assert_instance_of Sidekiq::Enqueuer::Worker::Param, instance.params.last
            end
          end
        end

        describe '#trigger' do
          let(:instance) { Sidekiq::Enqueuer::Worker::Instance.new(HardWorker, false) }

          it 'expects enqueue to be called' do
            Sidekiq::Client.stub(:enqueue_to, true) do
              assert_equal true, instance.trigger([])
            end
          end
        end

        describe '#trigger_in' do
          let(:instance) { Sidekiq::Enqueuer::Worker::Instance.new(HardWorker, false) }

          it 'expects enqueue to be called' do
            Sidekiq::Client.stub(:enqueue_to_in, true) do
              assert_equal true, instance.trigger_in(1, [])
            end
          end
        end

        describe '#name' do
          let(:instance) { Sidekiq::Enqueuer::Worker::Instance.new(HardWorker, false) }

          it 'expects to have the correct name' do
            assert_equal 'HardWorker', instance.name
          end
        end

        describe '#trigger_method' do
          let(:instance) { Sidekiq::Enqueuer::Worker::Instance.new(HardWorker, false) }

          it 'expects to return an instance of Trigger klass' do
            assert_instance_of Sidekiq::Enqueuer::Worker::Trigger, instance.send(:trigger_job, [])
          end
        end
      end
    end
  end
end
