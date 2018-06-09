# frozen_string_literal: true

module Minitest
  module Assertions
    def assert_valid(actual, *args)
      assert valid?(actual, *args),
             "Expected #{actual.inspect} to be valid?"
    end

    def refute_valid(actual, *args)
      refute valid?(actual, *args),
             "Expected #{actual.inspect} to not be valid?"
    end

    private

    def valid?(actual, *args)
      actual.valid?(*args)
    end
  end
end
