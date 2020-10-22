# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Configuration do
  describe "#jobs" do
    subject { config.available_jobs }

    before { config.jobs = %w[NoParamWorker HardWorker] }

    let(:config) { described_class.new }

    it { is_expected.to eq([HardWorker, NoParamWorker]) }
  end
end
