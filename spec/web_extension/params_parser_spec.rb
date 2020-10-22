# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::WebExtension::ParamsParser do
  let(:parser) { described_class.new(params, worker) }
  let(:worker) do
    Sidekiq::Enqueuer::Worker::Instance.new(WorkerWithOptionalParams, async: false)
  end

  describe "#initializer" do
    subject(:parsed_params) { parser.raw_params }

    let(:parser) { described_class.new(params, worker) }
    let(:params) { Hash["userId" => "value"] }

    it "expects a correct name assignment" do
      expect(parsed_params).to be_an_instance_of(Hash)
      expect(parsed_params).to eq("userId" => "value")
    end
  end

  describe "#process" do
    subject(:process_result) { parser.process }

    context "with only string parameters" do
      let(:params) do
        { "required_param" => "valueParamUserId", "optional_param" => "valueTesting" }
      end

      it "with params to return an array of values" do
        expect(process_result).to be_an_instance_of(Array)
        expect(process_result).to eq(["valueParamUserId", "valueTesting", nil])
      end
    end

    context "with the first parameter as a hash and a second as string" do
      let(:params) { Hash["required_param" => "value1", "optional_param" => "valueTesting"] }

      it "parses params to return an array of values" do
        expect(process_result).to be_an_instance_of(Array)
        expect(process_result).to eq(["value1", "valueTesting", nil])
      end
    end

    context "with empty values" do
      let(:params) { Hash["required_param" => "testing", "optional_param" => ""] }

      it "parses params to return an array of values" do
        expect(process_result).to be_an_instance_of(Array)
        expect(process_result).to eq(["testing", nil, nil])
      end
    end

    context "with no value for required fields" do
      let(:params) { Hash["required_param" => "", "optional_param" => ""] }

      it "parses params and raises an error" do
        expect { process_result }.to raise_error(described_class::NoProvidedValueForRequiredParam)
      end
    end
  end
end
