require_relative '../test_helper'

module Command
  class TransferTest < Minitest::Test

    class OuterCommand
      include Command

      output :foo, :bar

      def call(inner_args)
        self.foo = 'foo'
        transfer! FailOnStringCommand.call(inner_args)
        self.bar = 'bar'
      end

      private

      attr_accessor :foo, :bar
    end

    class FailOnStringCommand
      include Command

      output :inner_output

      def call(value)
        self.inner_output = value
        error! value if value.is_a?(String)
      end

      private

      attr_accessor :inner_output
    end

    def test_result_matches_inner_successful
      result = OuterCommand.call('this is an error')
      refute_successful result

      result = OuterCommand.call(42)
      assert_successful result
    end

    def test_transfer_merges_outputs
      result = OuterCommand.call(42)
      assert_respond_to result, :foo
      assert_equal 'foo', result.foo

      assert_respond_to result, :inner_output
      assert_equal 42, result.inner_output
    end

    def test_failed_transfer_ends_call
      result = OuterCommand.call('this is an error')
      assert_respond_to result, :bar
      assert_nil result.bar
    end

    def test_transfer_merges_errors
      result = OuterCommand.call('this is an error')
      assert_equal result.error, 'this is an error'
    end
  end
end
