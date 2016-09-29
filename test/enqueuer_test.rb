require "test_helper"

module Sidekiq
  describe "Enqueuer" do
    before do
      Sidekiq.redis = REDIS
      Sidekiq.redis {|c| c.flushdb }
    end

    it "get_job_modules" do
      modules = Sidekiq::Enqueuer.get_job_modules
      assert_equal 2, modules.size

      assert_equal true, modules.include?(HardWorker)
      assert_equal true, modules.include?(NoParamWorker)
    end

    it "get_job_classes" do
      classes = Sidekiq::Enqueuer.get_job_classes
      assert_equal 1, classes.size
      assert_equal true, classes.include?(HardJob)
      assert_equal false, classes.include?(NoParamWorker)
    end

    it '.get_jobs' do
      jobs = Sidekiq::Enqueuer.get_jobs
      assert_equal 3, jobs.size
      assert_equal HardJob, jobs.first
      assert_equal HardWorker, jobs.second
      assert_equal NoParamWorker, jobs.last
    end

    it "is_job_class?" do
      assert_equal true, Sidekiq::Enqueuer.is_job_class?(HardJob)
    end

    it "has_worker_module?" do
      assert_equal true, Sidekiq::Enqueuer.has_worker_module?(HardWorker)
    end

    it "perform_async, ActiveJob" do
      Sidekiq::Enqueuer.perform_async(HardJob, ['v1', 'v2'])

      default_queue = Sidekiq::Queue.new(:default)
      assert_equal 1, default_queue.size
      assert_equal 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper', default_queue.first.klass
      assert_equal 'HardJob', default_queue.first.args.first['job_class']
      assert_equal ['v1','v2'], default_queue.first.args.first['arguments']
    end

    it "perform_async, Sidkeiq::Worker" do
      Sidekiq::Enqueuer.perform_async(HardWorker, ['v1', 'v2'])

      default_queue = Sidekiq::Queue.new(:default)
      assert_equal 1, default_queue.size
      assert_equal 'HardWorker', default_queue.first.klass
      assert_equal ['v1','v2'], default_queue.first.args
    end

    it "perform_in, ActiveJob" do
      Sidekiq::Enqueuer.perform_in(HardJob, 120, ['v1', 'v2'])

      ss = Sidekiq::ScheduledSet.new
      assert_equal 1, ss.size
      assert_equal 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper', ss.first.klass
      assert_equal ['v1','v2'], ss.first.args.first['arguments']
      assert_equal 120, (ss.first.at - Time.now).ceil
    end

    it "perform_in, Sidekiq::Worker" do
      Sidekiq::Enqueuer.perform_in(HardWorker, 120, ['v1', 'v2'])

      ss = Sidekiq::ScheduledSet.new
      assert_equal 1, ss.size
      assert_equal 'HardWorker', ss.first.klass
      assert_equal ['v1','v2'], ss.first.args
      assert_equal 120, (ss.first.at - Time.now).ceil
    end

    it "values_parser, should strip value" do
      values = [' a ', 'b']
      parsed_values = Sidekiq::Enqueuer.values_parser(values)

      assert_equal ['a', 'b'], parsed_values
    end

    it "values_parser, should parse hash" do
      values = [' {k1: v1, k2: v2}', 'b']
      parsed_values = Sidekiq::Enqueuer.values_parser(values)

      assert_equal [{'k1'=> 'v1', 'k2'=> 'v2'}, 'b'], parsed_values
    end

  end
end