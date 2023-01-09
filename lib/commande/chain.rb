# frozen_string_literal: true

module Commande
  class Chain
    include Commande

    output :chain_result

    def initialize(*commands)
      self.commands = commands
    end

    def chain(*commands)
      new(*self.commands, *commands)
    end

    def valid(**_args)
      error! 'needs at least one command' if commands.empty?

      true
    end

    def call(**args)
      self.chain_result = commands.inject(InitialCommandResult.new(args)) do |last_result, current_command|
        current_result = current_command.call(**last_result.payload.dup)

        transfer_logs current_result
        transfer_errors current_result

        fail! unless transfer_success? current_result
        current_result
      end
    end

    private

    attr_accessor :commands, :chain_result

    class InitialCommandResult
      def initialize(args)
        self.payload = args
      end

      attr_reader :payload

      private

      attr_writer :payload
    end
  end
end
