# frozen_string_literal: true

shared_context "web extension api context" do
  include Rack::Test::Methods

  subject(:app) { Sidekiq::Web }
end
