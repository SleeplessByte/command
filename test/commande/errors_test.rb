# frozen_string_literal: true

require_relative '../test_helper'

module Commande
  class ErrorsTest < Minitest::Test

    class CommandeWithError
      include Commande

      def call
        error 'first'
        error! 'fatal'
        error 'nope'
      end
    end

    def test_result_is_not_successful
      result = CommandeWithError.call
      refute_successful result
    end

    def test_result_has_first_error
      result = CommandeWithError.call
      assert_equal 'first', result.error
    end

    def test_result_has_fatal_error
      result = CommandeWithError.call
      assert_with_error 'fatal', result
    end

    def test_result_stopped_on_fatal_error
      result = CommandeWithError.call
      refute_with_error 'nope', result
    end
  end
end
