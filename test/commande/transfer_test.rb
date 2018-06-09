# frozen_string_literal: true

require_relative '../test_helper'

module Commande
  class TransferTest < Minitest::Test

    class OuterCommande
      include Commande

      output :foo, :bar

      def call(inner_args)
        self.foo = 'foo'
        transfer! FailOnStringCommande.call(inner_args)
        self.bar = 'bar'
      end

      private

      attr_accessor :foo, :bar
    end

    class FailOnStringCommande
      include Commande

      output :inner_output

      def call(value)
        self.inner_output = value
        error! value if value.is_a?(String)
      end

      private

      attr_accessor :inner_output
    end

    def test_result_matches_inner_successful
      result = OuterCommande.call('this is an error')
      refute_successful result

      result = OuterCommande.call(42)
      assert_successful result
    end

    def test_transfer_merges_outputs
      result = OuterCommande.call(42)
      assert_respond_to result, :foo
      assert_equal 'foo', result.foo

      assert_respond_to result, :inner_output
      assert_equal 42, result.inner_output
    end

    def test_failed_transfer_ends_call
      result = OuterCommande.call('this is an error')
      assert_respond_to result, :bar
      assert_nil result.bar
    end

    def test_transfer_merges_errors
      result = OuterCommande.call('this is an error')
      assert_equal result.error, 'this is an error'
    end
  end
end
