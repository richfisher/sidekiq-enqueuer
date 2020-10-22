# frozen_string_literal: true

RSpec.describe Sidekiq::Enqueuer::WebExtension::Loader do
  include_context "web extension api context"

  before { Timecop.freeze("1970-01-01 00:00:00") }

  before do
    Sidekiq.redis = REDIS
    Sidekiq.redis(&:flushdb)
  end

  before do
    Sidekiq::Enqueuer.configure do |config|
      config.jobs = %w[NoParamWorker HardWorker HardJob]
    end
  end

  describe "GET /" do
    it "can display home with enqueuer tab" do
      get "/"

      expect(last_response).to be_successful
      expect(last_response.body).to include("Sidekiq", "Enqueuer")
    end
  end

  describe "GET /enqueuer" do
    context "with a supported Worker class" do
      it "can display Enqueuer with HardWorker" do
        get "/enqueuer"

        expect(last_response).to be_successful
        expect(last_response.body).to include("HardWorker", "NoParamWorker", "HardJob")
      end

      it "can display HardWorker form" do
        get "/enqueuer/HardWorker"

        expect(last_response).to be_successful
        expect(last_response.body).to include("HardWorker", "param1", "param2")
      end
    end

    context "given an unsupported Worker class" do
      it "can display Enqueuer with HardJob" do
        get "/enqueuer"

        expect(last_response).to be_successful
        expect(last_response.body).to include("HardJob")
      end

      it "can display HardJob form" do
        get "/enqueuer/HardJob"

        expect(last_response).to be_successful
        expect(last_response.body).to include("HardJob", "param1", "param2")
      end
    end
  end

  describe "POST /enqueuer" do
    context "providing valid parameters" do
      it "post form, enqueue a HardWorker" do
        default_queue = Sidekiq::Queue.new

        post "/enqueuer", job_class_name: "HardWorker",
                          perform: { param1: "v1", param2: "v2" },
                          submit: "Enqueue"

        expect(last_response).to be_redirect
        expect(default_queue.size).to eq(1)
        expect(default_queue.first.klass).to eq("HardWorker")
        expect(default_queue.first.args).to eq(%w[v1 v2])
      end

      it "post form, enqueue a HardJob" do
        default_queue = Sidekiq::Queue.new(:default)

        post "/enqueuer", job_class_name: "HardJob",
                          perform: { param1: "v1", param2: "v2" },
                          submit: "Enqueue"

        expect(last_response).to be_redirect
        expect(default_queue.size).to eq(1)
        expect(default_queue.first.klass).to eq(
          "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper",
        )
        expect(default_queue.first.args.first["job_class"]).to eq("HardJob")
        expect(default_queue.first.args.first["arguments"]).to eq(%w[v1 v2])
      end
    end

    context "post form, schedule jobs to the future" do
      it "post form, schedule a HardWorker" do
        ss = Sidekiq::ScheduledSet.new

        post "/enqueuer", job_class_name: "HardWorker",
                          perform: { param1: "v1", param2: "v2" },
                          enqueue_in: 120,
                          submit: "Schedule"

        expect(last_response).to be_redirect
        expect(ss.size).to eq(1)
        expect(ss.first.klass).to eq("HardWorker")
        expect(ss.first.args).to eq(%w[v1 v2])
        expect(ss.first.at).to eq(120.seconds.from_now)
      end

      it "post form, schedule a HardJob" do
        ss = Sidekiq::ScheduledSet.new

        post "/enqueuer", job_class_name: "HardJob",
                          perform: { param1: "v1", param2: "v2" },
                          enqueue_in: 120,
                          submit: "Schedule"

        expect(last_response).to be_redirect
        expect(ss.size).to eq(1)
        expect(ss.first.klass).to eq("ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper")
        expect(ss.first.args.first["arguments"]).to eq(%w[v1 v2])
        expect(ss.first.at).to eq(120.seconds.from_now)
      end
    end
  end
end
