# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Worker::Instance do
  describe "#initializer" do
    context "with perform with parameters" do
      subject(:instance) { described_class.new(HardWorker, async: false) }

      it "expects to have a defined perform_method" do
        expect(instance.instance_method).to eq(:perform)
      end

      it "expects to have a correct async attr " do
        expect(instance.async).to be_falsey
      end

      it "expects to deduce perform method params correctly" do
        expect(instance.params.size).to eq(2)
        expect(instance.params.first).to be_an_instance_of(Sidekiq::Enqueuer::Worker::Param)
        expect(instance.params.last).to be_an_instance_of(Sidekiq::Enqueuer::Worker::Param)
      end
    end

    context "with perform without parameters" do
      subject(:instance) { described_class.new(WorkerWithNoParams, async: false) }

      it "expects to have a defined perform_method" do
        expect(instance.instance_method).to eq(:perform)
      end

      it "expects to have a currect async attr" do
        expect(instance.async).to be_falsey
      end

      it "expects perform method params to be empty" do
        expect(instance.params).to be_empty
      end
    end

    context "with a method different than perform" do
      subject(:instance) { described_class.new(WorkerWithPerformAsync, async: false) }

      it "expects to have a defined perform_method" do
        expect(instance.instance_method).to eq(:perform_async)
      end

      it "expects to have a correct async attr" do
        expect(instance.async).to be_falsey
      end

      it "expects to deduce perform method params correctly" do
        expect(instance.params.size).to eq(2)
        expect(instance.params.first).to be_an_instance_of(Sidekiq::Enqueuer::Worker::Param)
        expect(instance.params.last).to be_an_instance_of(Sidekiq::Enqueuer::Worker::Param)
      end
    end
  end

  describe "#trigger" do
    subject(:instance) { described_class.new(HardWorker, async: false) }

    before { expect(Sidekiq::Client).to receive(:enqueue_to).and_return(true) }

    it "expects enqueue to be called" do
      expect(instance.trigger([])).to be_truthy
    end
  end

  describe "#trigger_in" do
    subject(:instance) { described_class.new(HardWorker, async: false) }

    before { expect(Sidekiq::Client).to receive(:enqueue_to_in).and_return(true) }

    it "expects enqueue to be called" do
      expect(instance.trigger_in(1, [])).to be_truthy
    end
  end

  describe "#name" do
    subject(:instance) { described_class.new(HardWorker, async: false) }

    it "expects to have the correct name" do
      expect(instance.name).to eq("HardWorker")
    end
  end

  describe "#trigger_method" do
    subject(:instance) { described_class.new(HardWorker, async: false) }

    it "expects to return an instance of Trigger klass" do
      expect(instance.send(:trigger_job, [])).to be_an_instance_of(
        Sidekiq::Enqueuer::Worker::Trigger,
      )
    end
  end
end
