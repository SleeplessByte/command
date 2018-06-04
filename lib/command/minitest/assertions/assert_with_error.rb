module Minitest
  module Assertions
    def assert_with_error(expected, actual)
      assert with_error(expected, actual),
             "Expected #{actual.errors} to have an error '#{expected}'."
    end

    def refute_with_error(expected, actual)
      refute with_error(expected, actual),
             "Expected #{actual.errors} to not have an error '#{expected}'."
    end

    private

    def with_error(expected, actual)
      actual.errors.any? do |error|
        expected == error
      end
    end
  end
end
