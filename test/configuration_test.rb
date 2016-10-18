require 'test_helper'

module Sidekiq
  module Enqueuer
    describe Configuration do
      before do
        Sidekiq.redis = REDIS
        Sidekiq.redis(&:flushdb)
      end

      describe 'all_jobs' do
        describe 'defined jobs' do
          let(:config) { Sidekiq::Enqueuer::Configuration.new }
          before do
            config.jobs = [NoParamWorker, HardWorker]
          end

          it 'includes all described jobs' do
            assert_equal true, config.all_jobs.include?(HardWorker)
            assert_equal true, config.all_jobs.include?(NoParamWorker)
          end

          it 'orders jobs by mane ascending' do
            assert_equal HardWorker, config.all_jobs[0]
            assert_equal NoParamWorker, config.all_jobs[1]
          end
        end

        # TODO: Create a rails app, add some jobs and use it as test app
        # describe 'loading all jobs' do
        #   let(:config) { Sidekiq::Enqueuer::Configuration.new }
        #   before do
        #     config.all_jobs
        #   end

        #   it 'includes all described jobs' do
        #     assert_equal true, config.all_jobs.include?(HardWorker)
        #     assert_equal true, config.all_jobs.include?(NoParamWorker)
        #   end

        #   it 'orders jobs by mane ascending' do
        #     assert_equal HardWorker, config.all_jobs.first
        #     assert_equal NoParamWorker, config.all_jobs.last
        #   end
        # end
      end

      describe 'sort' do
        let(:config) { Sidekiq::Enqueuer::Configuration.new }
        let(:defined_jobs) { [NoParamWorker, HardWorker] }

        it 'orders jobs by mane ascending' do
          assert_equal HardWorker, config.send(:sort, defined_jobs)[0]
          assert_equal NoParamWorker, config.send(:sort, defined_jobs)[1]
        end
      end

      # TODO: Create a rails app, add some jobs and use it as test app
      # describe 'application_jobs' do
      #   let(:config) { Sidekiq::Enqueuer::Configuration.new }

      #   it 'retrieves jobs that includes Sidekiq::Worker' do
      #     assert_equal true, config.send(:application_jobs).include?(HardWorker)
      #     assert_equal true, config.send(:application_jobs).include?(NoParamWorker)
      #   end

      #   it 'ignores internal Sidekiq::Workers' do
      #     assert_equal false, config.send(:application_jobs).include?(Sidekiq::Extension)
      #     assert_equal false, config.send(:application_jobs).include?(ActiveJob::QueueAdapters)
      #   end
      # end
    end
  end
end
