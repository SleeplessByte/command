require_relative '../test_helper'

module Command
  class ErrorsTest < Minitest::Test

    class CommandWithLog
      include Command

      def call
        log 'message'
      end
    end

    class CommandWithLogAndError
      include Command

      def call
        log 'message'
        error 'error'
      end
    end

    def test_result_success_is_unchanged
      result = CommandWithLog.call
      assert_successful result

      result = CommandWithError.call
      refute_successful result
    end

    def test_result_has_has_log
      result = CommandWithLog.call
      assert_equal 'message', result.logs.first
    end
  end
end
