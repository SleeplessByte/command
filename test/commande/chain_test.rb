# frozen_string_literal: true

require_relative '../test_helper'
require 'commande/chain'

module Commande
  class ChainTest < Minitest::Test

    class StartCommand
      include Commande

      output :foo, :baz

      def valid?(test:)
        error! 'test must at least be 3' if test < 3

        true
      end

      def call(test:)
        self.foo = 'foo' * test
        self.not_an_output = 'not_an_output'
      end

      private

      attr_accessor :foo, :baz, :not_an_output
    end

    class SecondCommand
      include Commande

      output :result

      def call(foo:, **_opts)
        self.result = foo
      end

      private

      attr_accessor :result
    end

    def test_can_chain_successfull
      result = Chain.new(StartCommand, SecondCommand).call(test: 3)
      assert_respond_to(result, :chain_result)
      chain_result = result.chain_result

      assert result.successful?
      assert_respond_to(chain_result, :result)
      assert_equal 'foo' * 3, chain_result.result
    end

    def test_chain_breaks_when_call_blows
      result = Chain.new(StartCommand, SecondCommand).call(test: 2)

      refute result.successful?
      assert_respond_to(result, :chain_result)
      chain_result = result.chain_result
      refute_respond_to(chain_result, :result)
    end

    def test_broken_chain_retains_errors
      result = Chain.new(StartCommand, SecondCommand).call(test: 2)

      refute result.successful?
      assert_equal('test must at least be 3', result.error)
    end

  end
end
