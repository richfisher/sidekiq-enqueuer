# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::Worker::Param do
  describe "#initializer" do
    context "with required param" do
      subject(:param) { described_class.new("userId", :req) }

      it "expects a correct name assignment" do
        expect(param.name).to eq("userId")
      end

      it { expect(param.required?).to be_truthy }
      it { expect(param.optional?).to be_falsey }
    end

    context "with optional param" do
      subject(:param) { described_class.new("userId", :opt) }

      it "expects a correct name assignment" do
        expect(param.name).to eq("userId")
      end

      it { expect(param.required?).to be_falsey }
      it { expect(param.optional?).to be_truthy }
    end
  end

  describe "#label" do
    context "with a required condition" do
      subject(:param) { described_class.new("userId", :req) }

      it "expects a correct name assignment" do
        expect(param.label).to eq("required")
      end
    end

    context "with an optional condition" do
      subject(:param) { described_class.new("userId", :opt) }

      it "expects a correct name assignment" do
        expect(param.label).to eq("optional")
      end
    end
  end
end
