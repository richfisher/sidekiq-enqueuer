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

            it 'expects a correct condition assignment' do
              assert_equal 'required', param.condition
            end
          end

          describe 'having optional param' do
            let(:param) { Sidekiq::Enqueuer::Worker::Param.new('userId', :opt) }

            it 'expects a correct name assignment' do
              assert_equal 'userId', param.name
            end

            it 'expects a correct condition assignment' do
              assert_equal 'optional', param.condition
            end
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
