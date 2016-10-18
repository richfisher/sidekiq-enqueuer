require 'test_helper'

module Sidekiq
  module Enqueuer
    describe Enqueuer do
      before do
        Sidekiq.redis = REDIS
        Sidekiq.redis(&:flushdb)
      end

      describe 'configuration' do
        let(:config) { Sidekiq::Enqueuer.configuration }
        it 'configuration' do
          assert_instance_of Sidekiq::Enqueuer::Configuration, config
        end
      end

      describe 'configure' do
        before do
          Sidekiq::Enqueuer.configure do |config|
            config.jobs = [NoParamWorker, HardJob]
          end
        end

        let(:enqueuer) { Sidekiq::Enqueuer }

        it 'expects to have two jobs' do
          assert_equal 2, enqueuer.all_jobs.size
        end

        it 'expects to create wrappers of the provided jobs' do
          assert_equal 2, enqueuer.all_jobs.size
          assert_instance_of Sidekiq::Enqueuer::Worker::Instance, enqueuer.all_jobs.first
          assert_instance_of Sidekiq::Enqueuer::Worker::Instance, enqueuer.all_jobs.last
        end

        it 'expects the wrapper instances to be for the jobs defined in the config file' do
          assert_equal true, enqueuer.all_jobs.map(&:name).include?(NoParamWorker.name)
          assert_equal true, enqueuer.all_jobs.map(&:name).include?(HardJob.name)
        end

        it 'expects to have ordered jobs' do
          assert_equal HardJob, enqueuer.all_jobs.first.job
          assert_equal NoParamWorker, enqueuer.all_jobs.last.job
        end
      end
    end
  end
end
