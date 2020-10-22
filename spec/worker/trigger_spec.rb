# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Worker::Trigger do
  describe "#initializer" do
    context "with job with sidekiq options" do
      subject(:trigger) { described_class.new(WorkerWithDefinedQueue, []) }

      it "expects queue to be correctly setup" do
        expect(trigger.queue).to eq("custom_queue")
      end

      it "expects to have an empty arguments " do
        expect(trigger.args_with_values).to be_empty
      end
    end

    context "with job without sidekiq options" do
      subject(:trigger) { described_class.new(HardJob, %w[test test2]) }

      it "expects queue to be correctly setup" do
        expect(trigger.queue).to eq("default")
      end

      it "expects to have an empty arguments " do
        expect(trigger.args_with_values).to eq(%w[test test2])
      end
    end
  end

  describe "#enqueue" do
    context "with a sidekiq job" do
      subject(:trigger) { described_class.new(WorkerWithDefinedQueue, []) }

      before { expect(Sidekiq::Client).to receive(:enqueue_to).and_return(true) }

      it "expects enqueue to be called" do
        expect(trigger.enqueue).to be_truthy
      end
    end

    context "with an ActiveJob" do
      subject(:trigger) { described_class.new(HardJob, []) }

      before { expect(HardJob).to receive(:perform_later).and_return(true) }

      it "returns true" do
        expect(trigger.enqueue).to be_truthy
      end
    end

    context "with unknown job type" do
      subject(:trigger) { described_class.new(Class.new, []) }

      it "raises corresponding error" do
        expect { trigger.enqueue }.to raise_error(described_class::UnsupportedJobType)
      end
    end
  end

  describe "#enqueue_in" do
    context "with a sidekiq job" do
      subject(:trigger) { described_class.new(WorkerWithDefinedQueue, %w[test test2]) }

      before { expect(Sidekiq::Client).to receive(:enqueue_to_in).and_return(true) }

      it "expects enqueue to be called" do
        expect(trigger.enqueue_in(1)).to be_truthy
      end
    end

    context "with an ActiveJob" do
      subject(:trigger) { described_class.new(HardJob, []) }

      before { expect(HardJob).to receive_message_chain(:set, :perform_later).and_return(true) }

      it "expects enqueue to be called" do
        expect(trigger.enqueue_in(1)).to be_truthy
      end
    end

    context "with unknown job type" do
      subject(:trigger) { described_class.new(Class.new, []) }

      it "raises corresponding error" do
        expect { trigger.enqueue_in(1) }.to raise_error(described_class::UnsupportedJobType)
      end
    end
  end

  describe "#deduce_queue" do
    context "with job with sidekiq options" do
      subject(:trigger) { described_class.new(WorkerWithDefinedQueue, []) }

      it "expects queue to be correctly setup" do
        expect(trigger.send(:deduce_queue)).to eq("custom_queue")
      end
    end

    context "with job without sidekiq options" do
      subject(:trigger) { described_class.new(HardJob, %w[test test2]) }

      it "expects queue to be correctly setup" do
        expect(trigger.send(:deduce_queue)).to eq("default")
      end
    end
  end

  describe "#sidekiq_job?" do
    subject(:trigger) { described_class.new(WorkerWithDefinedQueue, []) }

    it "expects return true when Sidekiq::Worker is configured" do
      expect(trigger.send(:sidekiq_job?)).to be_truthy
    end
  end
end
