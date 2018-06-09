# frozen_string_literal: true

require_relative '../test_helper'

module Commande
  class OutputsTest < Minitest::Test

    class CommandeWithOutput
      include Commande

      output :foo, :baz

      def call
        self.foo = 'foo'
        self.not_an_output = 'not_an_output'
      end

      private

      attr_accessor :foo, :baz, :not_an_output
    end

    def test_result_has_output
      result = CommandeWithOutput.call

      assert_respond_to(result, :foo)
      assert_equal 'foo', result.foo
    end

    def test_result_has_output_even_if_not_assigned
      result = CommandeWithOutput.call

      assert_respond_to(result, :baz)
      assert_nil result.baz
    end

    def test_result_does_not_have_other_instance_variables
      result = CommandeWithOutput.call
      refute_respond_to(result, :not_an_output)
    end
  end
end
