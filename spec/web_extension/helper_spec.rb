# frozen_string_literal: true

class TestHelperClass
  include Sidekiq::Enqueuer::WebExtension::Helper

  def params
    {
      "post" => {
        "required_param" => "value1",
        "optional_param" => "testing",
        "optional_param2" => "testing2",
      },
    }
  end
end

RSpec.describe Sidekiq::Enqueuer::WebExtension::Helper do
  let(:helper) { TestHelperClass.new }
  let(:worker) do
    Sidekiq::Enqueuer::Worker::Instance.new(WorkerWithOptionalParams, async: false)
  end

  describe "#get_params_by_action" do
    context "with valid params for the required action" do
      subject(:params) { helper.get_params_by_action("post", worker) }

      it "returns a list of values passed as parameters" do
        expect(params).to eq(%w[value1 testing testing2])
      end
    end

    context "providing invalid action params" do
      subject(:params) { helper.get_params_by_action("none", worker) }

      it "returns empty list since there is no 'none' param" do
        expect(params).to be_empty
      end
    end
  end

  describe "#find_job_by_class_name" do
    before do
      Sidekiq::Enqueuer.configure do |config|
        config.jobs = %w[NoParamWorker HardWorker]
      end
    end

    context "providing a valid job name" do
      subject(:job) { helper.find_job_by_class_name("HardWorker") }

      it "returns the single instance of the job to use" do
        expect(job).to be_an_instance_of(Sidekiq::Enqueuer::Worker::Instance)
        expect(job.name).to eq("HardWorker")
      end
    end

    context "providing a valid job" do
      subject(:job) { helper.find_job_by_class_name(HardWorker) }

      it "returns the single instance of the job to use" do
        expect(job).to be_an_instance_of(Sidekiq::Enqueuer::Worker::Instance)
        expect(job.name).to eq("HardWorker")
      end
    end

    context "providing an invalid job name" do
      subject(:job) { helper.find_job_by_class_name("TestingWorker") }

      it "returns nil since there is no such job" do
        expect(job).to be_nil
      end
    end
  end
end
