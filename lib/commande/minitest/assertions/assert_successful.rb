# frozen_string_literal: true

module Minitest
  module Assertions
    def assert_successful(actual)
      assert successful?(actual),
             "Expected #{actual.inspect} to be successful?. Actual got these errors: #{actual.errors || ''}"
    end

    def refute_successful(actual)
      refute successful?(actual),
             "Expected #{actual.inspect} to not be successful?"
    end

    private

    def successful?(actual)
      actual.successful?
    end
  end
end
