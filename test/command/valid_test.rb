require_relative '../test_helper'

module Command
  class ValidTest < Minitest::Test

    class ValidatableCommand
      include Command

      output :foo

      def call(_expression)
        self.foo = 'foo'
      end

      def valid?(expression)
        # dynamic validation
        expression
      end

      private

      attr_accessor :foo
    end

    def test_result_matches_validation
      result = ValidatableCommand.call(true)
      assert_successful result

      result = ValidatableCommand.call(false)
      refute_successful result
    end

    def test_call_if_valid
      result = ValidatableCommand.call(true)
      assert_respond_to result, :foo
      assert_equal 'foo', result.foo
    end

    def test_dont_call_if_not_valid
      result = ValidatableCommand.call(false)
      assert_respond_to result, :foo
      assert_nil result.foo
    end
  end
end
