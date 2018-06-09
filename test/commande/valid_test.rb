# frozen_string_literal: true

require_relative '../test_helper'

module Commande
  class ValidTest < Minitest::Test

    class ValidatableCommande
      include Commande

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
      result = ValidatableCommande.call(true)
      assert_successful result

      result = ValidatableCommande.call(false)
      refute_successful result
    end

    def test_call_if_valid
      result = ValidatableCommande.call(true)
      assert_respond_to result, :foo
      assert_equal 'foo', result.foo
    end

    def test_dont_call_if_not_valid
      result = ValidatableCommande.call(false)
      assert_respond_to result, :foo
      assert_nil result.foo
    end
  end
end
