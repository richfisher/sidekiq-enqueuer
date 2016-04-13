ENV['RACK_ENV'] = 'test' # skip Rack Protection

require "minitest/autorun"
require "minitest/spec"
require "minitest/mock"

require "rack/test"

require "active_job"

require "sidekiq"
require "sidekiq/api"
require "sidekiq/enqueuer"

Sidekiq.logger.level = Logger::ERROR
REDIS = Sidekiq::RedisConnection.create(:url => "redis://localhost/15")

ActiveJob::Base.queue_adapter = :sidekiq
ActiveJob::Base.logger.level = Logger::ERROR

class HardWorker
  include Sidekiq::Worker
  def perform(param1, param2)
  end
end

class HardJob < ActiveJob::Base
  queue_as :default

  def perform(param1, param2)
  end
end