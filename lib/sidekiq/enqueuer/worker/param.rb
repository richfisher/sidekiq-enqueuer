module Sidekiq
  module Enqueuer
    module Worker
      class Param
        attr_reader :name, :label
        attr_accessor :value

        VALID_OPTIONS = { req: 'required', opt: 'optional' }.freeze

        def initialize(name, label)
          @name = name
          @label = VALID_OPTIONS[label]
        end

        def required?
          label == VALID_OPTIONS[:req]
        end

        def optional?
          !required?
        end
      end
    end
  end
end
