# frozen_string_literal: true

require 'commande/version'

module Commande
  class Result < BasicObject
    # Concrete methods
    #
    # @api private
    #
    # @see Commande::Result#respond_to_missing?
    METHODS = ::Hash[initialize:  true,
                     successful?: true,
                     failure?:    true,
                     fail!:       true,
                     prepare!:    true,
                     errors:      true,
                     error:       true,
                     logs:        true,
                     payload:     true].freeze

    # Initialize a new result
    #
    # @param payload [Hash] a payload to carry on
    #
    # @return [Commande::Result]
    #
    # @api private
    def initialize(payload = {})
      @payload = payload
      @errors  = []
      @logs = []
      @success = true
    end

    # Check if the current status is successful
    #
    # @return [TrueClass,FalseClass] the result of the check
    def successful?
      @success && errors.empty?
    end

    # Check if the current status is not successful
    #
    # @return [TrueClass,FalseClass] the result of the check
    def failure?
      !successful?
    end

    # Force the status to be a failure
    def fail!
      @success = false
    end

    # Returns all the errors collected during an operation
    #
    # @return [Array] the errors
    #
    # @see Commande::Result#error
    # @see Commande#call
    # @see Commande#error
    # @see Commande#error!
    def errors
      @errors.dup
    end

    # @api private
    def add_error(*errors)
      @errors << errors
      @errors.flatten!
      nil
    end

    # Returns the first errors collected during an operation
    #
    # @return [nil,String] the error, if present
    #
    #
    # @see Commande::Result#errors
    # @see Commande#call
    # @see Commande#error
    # @see Commande#error!
    def error
      errors.first
    end

    # Returns all the logs collected during an operation
    #
    # @return [Array] the errors
    #
    # @see Commande::Result#log
    # @see Commande#call
    def logs
      @logs.dup
    end

    # @api private
    def add_log(*logs)
      @logs << logs
      @logs.flatten!
      nil
    end

    # Prepare the result before to be returned
    #
    # @param payload [Hash] an updated payload
    #
    # @api private
    def prepare!(payload)
      @payload.merge!(payload)
      self
    end

    def payload
      @payload.dup
    end

    # Return the class for debugging purposes.
    #
    # @see http://ruby-doc.org/core/Object.html#method-i-class
    def class
      (class << self; self; end).superclass
    end

    # Bare minimum inspect for debugging purposes.
    #
    # @return [String] the inspect string
    #
    #
    # @see http://ruby-doc.org/core/Object.html#method-i-inspect
    #
    def inspect
      "#<#{self.class}:#{::Kernel.format('0x0000%<id>x', id: (__id__ << 1))}#{__inspect}>"
    end

    # Alias for __id__
    #
    # @return [Fixnum] the object id
    #
    # @see http://ruby-doc.org/core/Object.html#method-i-object_id
    def object_id
      __id__
    end

    # Returns true if responds to the given method.
    #
    # @return [TrueClass,FalseClass] the result of the check
    #
    # @see http://ruby-doc.org/core-2.2.1/Object.html#method-i-respond_to-3F
    def respond_to?(method_name, include_all = false)
      respond_to_missing?(method_name, include_all)
    end

    protected

    # @api private
    def method_missing(method_name, *)
      @payload.fetch(method_name) { super }
    end

    # @api private
    def respond_to_missing?(method_name, _include_all)
      method_name = method_name.to_sym
      METHODS[method_name] || @payload.key?(method_name)
    end

    # @api private
    def __inspect
      " @success=#{@success} @payload=#{@payload.inspect}"
    end
  end

  # Override for <tt>Module#included</tt>.
  #
  # @api private
  def self.included(base)
    super

    base.class_eval do
      extend ClassMethods
    end
  end

  # Commande interface
  # @since 1.1.0
  module Interface
    # Triggers the operation and return a result.
    #
    # All the instance variables marked as output will be available in the result.
    #
    # @return [Commande::Result] the result of the operation
    #
    # @raise [NoMethodError] if this isn't implemented by the including class.
    #
    # @example Expose instance variables in result payload as output
    #
    #   class Purchase
    #     include Commande
    #     output :buyer, :product, :transaction
    #
    #     def call(buyer:, product_code:)
    #       @product = Product.find_by(product_code: product_code)
    #       @buyer = Buyer.find_by(email: buyer)
    #       @transaction = Transaction.create(buyer: @buyer, product: @product)
    #     end
    #   end
    #
    #   result = Purchase.new.call(buyer: 'john@smith.com', product_code: 'i23af')
    #   result.failure? # => false
    #   result.successful? # => true
    #
    #   result.product  # => #<Product product_code: i23af>
    #   result.buyer    # => #<Buyer email: john@smith.com>
    #   result.foo      # => raises NoMethodError
    #
    def call(*args, &block)
      @__result = ::Commande::Result.new
      _call(*args) { super(*args, &block) }
    end

    private

    # @api private
    def _call(*args)
      catch :end do
        catch :fail do
          validate!(*args)
          yield
        end
      end

      _prepare!
    end

    # @since 1.1.0
    def validate!(*args)
      fail! unless valid?(*args)
    end
  end

  private

  # Check if proceed with <tt>#call</tt> invocation.
  # By default it returns <tt>true</tt>.
  #
  # Developers can override it.
  #
  # @return [TrueClass,FalseClass] the result of the check
  #
  def valid?(*)
    true
  end

  # Fail and interrupt the current flow.
  #
  def fail!
    @__result.fail!
    throw :fail
  end

  # Interrupt the current flow without failure
  #
  def end!
    throw :end
  end

  # Log an error without interrupting the flow.
  #
  # When used, the returned result won't be successful.
  #
  # @param message [String] the error message
  #
  # @return false
  #
  #
  # @see Commande#error!
  #
  def error(message)
    @__result.add_error message
    false
  end

  # Log an error AND interrupting the flow.
  #
  # When used, the returned result won't be successful.
  #
  # @param message [String] the error message
  #
  # @see Commande#error
  #
  def error!(message)
    error(message)
    fail!
  end

  # Persist a log message
  #
  # @param message [String] the log message
  #
  # @return true
  #
  # @see Commande#error
  #
  def log(message)
    @__result.add_log(message)
    true
  end

  protected

  ##
  # Copies errors and logs from sources and prefixes with a header:
  #
  # @param [Commande::Result, ApplicationRecord] source
  # @param [String] header
  # @return [TrueClass, FalseClass] true if successful, false otherwise
  #
  def transfer(source, header: nil)
    transfer_logs(source, header: header)
    transfer_outputs(source)
    transfer_errors(source, header: header)

    transfer_success?(source)
  end

  def transfer_logs(source, header: nil)
    return unless source.respond_to?(:logs)
    Array(source.logs).each do |l|
      log header ? ::Kernel.format('%<header>s: %<log>s', header: header, log: l) : l
    end
  end

  def transfer_outputs(source)
    return unless source.respond_to?(:payload)
    # Copy into current output
    @__result.prepare!(source.payload)

    # Copy into current commande
    source.payload.each do |name, value|
      setter = :"#{name}="
      if respond_to?(setter, true)
        __send__(setter, value)
        next
      end

      ivar = :"@#{name}"
      next unless instance_variable_defined?(ivar)
      instance_variable_set(ivar, value)
    end
  end

  ##
  # Checks the success of source and returns it
  #
  # @param [Commande::Result, ActiveRecord::Base] source
  # @return [TrueClass, FalseClass]
  #
  def transfer_success?(source)
    return source.successful? if source.respond_to?(:successful?)
    source.valid? && source.persisted?
  end

  def transfer_errors(source, header: nil)
    errors = source.errors
    errors = source.errors.full_messages if errors.respond_to?(:full_messages)
    Array(errors).each do |e|
      error header ? ::Kernel.format('%<header>s: %<error>s', header: header, error: e) : e
    end

    errors&.length&.positive?
  end

  ##
  # Copies the status of an interactor or active record object, #fail! if not successful
  #
  # ATTENTION: your setter needs to be PUBLIC to be copied to.
  #
  # @param [Commande::Result, ApplicationRecord] source
  # @see #transfer
  # @see Commande
  #
  def transfer!(source, header: nil)
    return if transfer(source, header: header)
    fail!
  end

  # @api private
  def _prepare!
    @__result.prepare!(_outputs)
  end

  # @api private
  def _outputs
    Hash[].tap do |result|
      self.class.outputs.each do |name, ivar|
        result[name] = instance_variable_defined?(ivar) ? instance_variable_get(ivar) : nil
      end
    end
  end

  # @api private
  module ClassMethods
    def call(*args, &block)
      new.call(*args, &block)
    end

    # @api private
    def self.extended(interactor)
      interactor.class_eval do
        singleton_class.class_eval do
          attr_accessor(:outputs)
        end

        self.outputs = {}
      end
    end

    def method_added(method_name)
      super
      return unless method_name == :call

      prepend Commande::Interface
    end

    # Expose local instance variables into the returning value of <tt>#call</tt>
    #
    # @param instance_variable_names [Symbol,Array<Symbol>] one or more instance
    #   variable names
    #
    # @see Commande::Result
    #
    def output(*instance_variable_names)
      instance_variable_names.each do |name|
        outputs[name.to_sym] = "@#{name}"
      end
    end

    alias outputs output
  end
end
