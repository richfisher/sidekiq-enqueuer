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