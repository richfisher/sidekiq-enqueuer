require 'test_helper'

module Sidekiq
  module Enqueuer
    module Worker
      describe Param do
        include Rack::Test::Methods

        describe '#initializer' do
          describe 'having required param' do
            let(:param) { Sidekiq::Enqueuer::Worker::Param.new('userId', :req) }

            it 'expects a correct name assignment' do
              assert_equal 'userId', param.name
            end

            it { assert_equal true, param.required? }
            it { assert_equal false, param.optional? }
          end

          describe 'having optional param' do
            let(:param) { Sidekiq::Enqueuer::Worker::Param.new('userId', :opt) }

            it 'expects a correct name assignment' do
              assert_equal 'userId', param.name
            end

            it { assert_equal false, param.required? }
            it { assert_equal true, param.optional? }
          end
        end

        describe '#label' do
          describe 'having a required condition' do
            let(:param) { Sidekiq::Enqueuer::Worker::Param.new('userId', :req) }

            it 'label to be required' do
              assert_equal 'required', param.label
            end
          end

          describe 'having an optional condition' do
            let(:param) { Sidekiq::Enqueuer::Worker::Param.new('userId', :opt) }

            it 'label to be required' do
              assert_equal 'optional', param.label
            end
          end
        end
      end
    end
  end
end
