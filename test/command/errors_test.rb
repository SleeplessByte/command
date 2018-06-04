require_relative '../test_helper'

module Command
  class ErrorsTest < Minitest::Test

    class CommandWithError
      include Command

      def call
        error 'first'
        error! 'fatal'
        error 'nope'
      end
    end

    def test_result_is_not_successful
      result = CommandWithError.call
      refute_successful result
    end

    def test_result_has_first_error
      result = CommandWithError.call
      assert_equal 'first', result.error
    end

    def test_result_has_fatal_error
      result = CommandWithError.call
      assert_with_error 'fatal', result
    end

    def test_result_stopped_on_fatal_error
      result = CommandWithError.call
      refute_with_error 'nope', result
    end
  end
end
