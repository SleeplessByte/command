require_relative '../test_helper'

module Command
  class OutputsTest < Minitest::Test

    class CommandWithOutput
      include Command

      output :foo, :baz

      def call
        self.foo = 'foo'
        self.not_an_output = 'not_an_output'
      end

      private

      attr_accessor :foo, :baz, :not_an_output
    end

    def test_result_has_output
      result = CommandWithOutput.call

      assert_respond_to(result, :foo)
      assert_equal 'foo', result.foo
    end

    def test_result_has_output_even_if_not_assigned
      result = CommandWithOutput.call

      assert_respond_to(result, :baz)
      assert_nil result.baz
    end

    def test_result_does_not_have_other_instance_variables
      result = CommandWithOutput.call
      refute_respond_to(result, :not_an_output)
    end
  end
end
