module Sidekiq::Enqueuer
  class Railtie < ::Rails::Railtie
    initializer "sidekiq_enqueuer_loaded" do
    end
  end
end