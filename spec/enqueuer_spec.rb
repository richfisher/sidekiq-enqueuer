# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer do
  subject(:jobs) { described_class.jobs }

  describe "#configure" do
    before do
      described_class.configure do |config|
        config.jobs = %w[NoParamWorker HardJob]
      end
    end

    it "holds two jobs" do
      expect(jobs.count).to eq(2)
    end

    it "wraps the jobs" do
      expect(jobs).to all(be_an_instance_of(Sidekiq::Enqueuer::Worker::Instance))
    end

    it "wrapped jobs are ordered and refer to workers" do
      expect(jobs.map(&:name)).to eq(%w[HardJob NoParamWorker])
    end
  end
end
