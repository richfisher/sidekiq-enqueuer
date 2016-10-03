require 'test_helper'
require 'sidekiq/web'

module Sidekiq
  module Enqueuer
    module WebExtension
      describe Loader do
        include Rack::Test::Methods

        def app
          Sidekiq::Web
        end
        before do
          Sidekiq.redis = REDIS
          Sidekiq.redis { |c| c.flushdb }
          Sidekiq::Enqueuer.configure do |config|
            config.jobs = [NoParamWorker, HardWorker, HardJob]
          end
        end

        describe 'Sidekiq Web Index page' do
          it 'can display home with enqueuer tab' do
            get '/'

            last_response.status.must_equal 200
            last_response.body.must_match 'Sidekiq'
            last_response.body.must_match 'Enqueuer'
          end
        end

        describe 'Index page' do
          describe 'given a supported Worker class' do
            it 'can display Enqueuer with HardWorker' do
              get '/enqueuer'

              last_response.body.must_match 'HardWorker'
              last_response.body.must_match 'NoParamWorker'
              last_response.body.must_match 'HardJob'
            end

            it 'can display HardWorker form' do
              get '/enqueuer/HardWorker'

              last_response.body.must_match 'HardWorker'
              last_response.body.must_match 'param1'
              last_response.body.must_match 'param2'
            end
          end

          describe 'given an unsupported Worker class' do
            it 'can display Enqueuer with HardJob' do
              get '/enqueuer'

              last_response.body.must_match 'HardJob'
            end

            it 'can display HardJob form' do
              get '/enqueuer/HardJob'

              last_response.body.must_match 'HardJob'
              last_response.body.must_match 'param1'
              last_response.body.must_match 'param2'
            end
          end
        end

        describe 'Post Page' do
          describe 'providing valid parameters' do
            it 'post form, enqueue a HardWorker' do
              default_queue = Sidekiq::Queue.new

              post '/enqueuer', job_class_name: 'HardWorker',
                                perform: { p1: 'v1', p2: 'v2' },
                                submit: 'Enqueue'
              last_response.status.must_equal 302

              assert_equal 1, default_queue.size
              assert_equal 'HardWorker', default_queue.first.klass
              assert_equal [['v1', 'v2']], default_queue.first.args
            end

            # it 'post form, enqueue a HardJob' do
            #   default_queue = Sidekiq::Queue.new(:default)

            #   post '/enqueuer', {job_class_name: 'HardJob', perform: {p1: 'v1', p2: 'v2'}, submit: 'Enqueue'}
            #   last_response.status.must_equal 302

            #   assert_equal 1, default_queue.size
            #   assert_equal 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper', default_queue.first.klass
            #   assert_equal 'HardJob', default_queue.first.args.first['job_class']
            #   assert_equal [['v1','v2']], default_queue.first.args.first['arguments']
            # end
          end

          describe 'post form, schedule jobs to the future' do
            it 'post form, schedule a HardWorker' do
              ss = Sidekiq::ScheduledSet.new

              post '/enqueuer', job_class_name: 'HardWorker',
                                perform: { p1: 'v1', p2: 'v2' },
                                enqueue_in: 120,
                                submit: 'Schedule'
              last_response.status.must_equal 302

              assert_equal 1, ss.size
              assert_equal 'HardWorker', ss.first.klass
              assert_equal [['v1', 'v2']], ss.first.args
              assert_equal 120, (ss.first.at - Time.now).ceil
            end

            # it 'post form, schedule a HardJob' do
            #   ss = Sidekiq::ScheduledSet.new

            #   post '/enqueuer', {job_class_name: 'HardJob', perform: {p1: 'v1', p2: 'v2'}, enqueue_in: 120, submit: 'Schedule'}
            #   last_response.status.must_equal 302

            #   assert_equal 1, ss.size
            #   assert_equal 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper', ss.first.klass
            #   assert_equal [['v1','v2']], ss.first.args.first['arguments']
            #   assert_equal 120, (ss.first.at - Time.now).ceil
            # end
          end
        end
      end
    end
  end
end
