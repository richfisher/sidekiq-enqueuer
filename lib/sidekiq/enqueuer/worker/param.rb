module Sidekiq
  module Enqueuer
    module Worker
      class Param
        attr_reader :name, :condition

        VALID_OPTIONS = { req: 'required', opt: 'optional' }.freeze

        def initialize(name, condition)
          @name = name
          @condition = VALID_OPTIONS[condition]
        end

        def label
          condition
        end
      end
    end
  end
end
