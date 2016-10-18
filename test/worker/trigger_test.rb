require 'test_helper'

module Sidekiq
  module Enqueuer
    module Worker
      describe Trigger do
        include Rack::Test::Methods

        describe '#initializer' do
          describe 'having job with sidekiq options' do
            let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(WorkerWithDefinedQueue, []) }

            it 'expects queue to be correctly setup' do
              assert_equal 'custom_queue', trigger.queue
            end

            it 'expects to have a empty arguments ' do
              assert 0, trigger.args_with_values.size
              assert_equal [], trigger.args_with_values
            end
          end

          describe 'having job without sidekiq options' do
            let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(HardJob, %w(test test2)) }

            it 'expects queue to be correctly setup' do
              assert_equal 'default', trigger.queue
            end

            it 'expects to have a empty arguments ' do
              assert 2, trigger.args_with_values.size
              assert_equal %w(test test2), trigger.args_with_values
            end
          end
        end

        describe '#enqueue' do
          describe 'having a sidekiq job' do
            let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(WorkerWithDefinedQueue, []) }

            it 'expects enqueue to be called' do
              Sidekiq::Client.stub(:enqueue_to, true) do
                assert_equal true, trigger.enqueue
              end
            end
          end

          describe 'having an ActiveJob' do
            it 'returns true' do
              trigger = Sidekiq::Enqueuer::Worker::Trigger.new(HardJob, [])
              HardJob.stub(:perform_later, true) do
                assert_equal true, trigger.enqueue
              end
            end
          end
        end

        describe '#enqueue_in' do
          describe 'having a sidekiq job' do
            let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(WorkerWithDefinedQueue, %w(test test2)) }

            it 'expects enqueue to be called' do
              Sidekiq::Client.stub(:enqueue_to_in, true) do
                assert_equal true, trigger.enqueue_in(1)
              end
            end
          end

          describe 'having an ActiveJob' do
            let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(HardJob, %w(test test2)) }

            it 'expects enqueue to be called' do
              trigger = Sidekiq::Enqueuer::Worker::Trigger.new(HardJob, [])
              HardJob.stub(:perform_later, true) do
                assert_equal true, trigger.enqueue
              end
            end
          end
        end

        describe '#deduce_queue' do
          describe 'having job with sidekiq options' do
            let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(WorkerWithDefinedQueue, []) }

            it 'expects queue to be correctly setup' do
              assert_equal 'custom_queue', trigger.send(:deduce_queue)
            end
          end

          describe 'having job without sidekiq options' do
            let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(HardJob, %w(test test2)) }

            it 'expects queue to be correctly setup' do
              assert_equal 'default', trigger.send(:deduce_queue)
            end
          end
        end

        describe '#sidekiq_job?' do
          let(:trigger) { Sidekiq::Enqueuer::Worker::Trigger.new(WorkerWithDefinedQueue, []) }

          it 'expects return true when Sidekiq::Worker is configured' do
            assert_equal true, trigger.send(:sidekiq_job?)
          end
        end
      end
    end
  end
end
