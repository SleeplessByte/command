# frozen_string_literal: true

require_relative '../test_helper'

module Commande
  class ErrorsTest < Minitest::Test

    class CommandeWithLog
      include Commande

      def call
        log 'message'
      end
    end

    class CommandeWithLogAndError
      include Commande

      def call
        log 'message'
        error 'error'
      end
    end

    def test_result_success_is_unchanged
      result = CommandeWithLog.call
      assert_successful result

      result = CommandeWithError.call
      refute_successful result
    end

    def test_result_has_has_log
      result = CommandeWithLog.call
      assert_equal 'message', result.logs.first
    end
  end
end
