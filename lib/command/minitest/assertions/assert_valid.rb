module Minitest
  module Assertions
    def assert_valid(actual)
      assert valid?(actual),
             "Expected #{actual.inspect} to be valid?"
    end

    def refute_valid(actual)
      refute valid?(actual),
             "Expected #{actual.inspect} to not be valid?"
    end

    private

    def valid?(actual)
      actual.valid?
    end
  end
end
