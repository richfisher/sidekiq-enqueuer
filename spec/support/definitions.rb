# frozen_string_literal: true

class NoParamWorker
  include Sidekiq::Worker

  def perform; end
end

class HardWorker
  include Sidekiq::Worker

  def perform(param1, param2); end
end

class HardJob < ActiveJob::Base
  queue_as :default

  def perform(param1, param2); end
end

class WorkerWithPerformAsync
  include Sidekiq::Worker

  def perform_async(param1, param2); end
end

class WorkerWithNoParams
  include Sidekiq::Worker

  def perform; end
end

class WorkerWithKeyValueParams
  include Sidekiq::Worker

  def perform(required_param:, optional_param: nil, optional_param2: nil); end
end

class WorkerWithOptionalParams
  include Sidekiq::Worker

  def perform(required_param, optional_param = nil, optional_param2 = nil); end
end

class WorkerWithDefinedQueue
  include Sidekiq::Worker

  sidekiq_options queue: :custom_queue

  def perform; end
end
