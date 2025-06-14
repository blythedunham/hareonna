# frozen_string_literal: true

module Clients
  # Base class for API clients using Faraday that provides a
  # consistent interface for making and logging HTTP requests. It is
  # meant to be subclassed for specific API clients but can also be
  # used standalone for simple API requests.
  # Instances should not be shared by multiple threads.
  #
  # @example
  # client = Clients::Base.new(connection_options: { url: 'https://example.com' })
  #     .on_success { |response| puts "Success!"; response.body }
  #     .on_error { |response, error| puts "Error: #{error.message}" }
  #     .get('someurl', { param1: 'value1' }, { 'Custom-Header' => 'value' })

  class Base
    include Utils::LogHelper

    # Default Faraday for the connection, can be overridden in subclasses.
    class_attribute :default_connection_options
    self.default_connection_options = {}

    # Default path for the client, can be overridden in subclasses.
    # This is used when no specific path is provided in the `get` method.
    class_attribute :default_path
    self.default_path = nil

    # The response from the last request made by the client.
    attr_reader :response

    # The Faraday::Connection instance used for making requests.
    attr_reader :connection

    # Initializes a new instance of the Base client.
    def initialize(connection_options: {}, **options, &block)
      reset_state
      all_options = default_connection_options.merge(connection_options)

      @connection = Faraday.new(all_options) do |faraday|
        # Call methods on subclasses
        configure_faraday_connection(faraday)

        # Configuration by caller
        yield(faraday) if block_given?
      end
    end

    # Makes a GET request to the specified path with optional parameters. This
    # matches the default Faraday signature for GET requests.
    #
    # @param [String] path - the endpoint path to send the GET request
    # @param [Hash] params Additional parameters to be sent with the request.
    # @param [Hash] headers Additional headers to be sent with the request.
    # @return [Hash, nil] The response body if successful, or nil if an error occurs.
    def get(path = nil, params = {}, headers = {})
      path||= default_path
      log(msg: "Making GET request", severity: "info", path: path)
      reset_state

      @response = connection.get(path, params, headers)
      @complete = true

      handle_response
    rescue => e
      log msg: "Error during GET request", e: e
      @on_error&.call(response, e)
    ensure
      @complete = true
      log(
        msg: "Completed GET request",
        path: path || "unknown",
        severity: "info",
        status: @response&.status,
        success: success?,
      )
      @on_complete&.call(response)
    end

    # Checks if the response was successful.
    # @return [Boolean] True if the response was successful, false otherwise.
    def success?
      !!(response && response.success?)
    end

    # Checks if the client has completed its request.
    # @return [Boolean] True if the client has completed its request, false otherwise.
    def complete?
      !!@complete
    end

    def on_error(&block)
      @on_error = block
      self
    end

    def on_success(&block)
      @on_success = block
      self
    end

    def on_complete(&block)
      @on_complete = block
      self
    end

    protected

    # Handles the response from the last request made by the client.
    # @return [Hash, nil] The response body if successful, or nil if an error occurs.
    def handle_response
      if !response&.success?
        @on_error&.call(response, nil)
      elsif @on_success.present?
        @on_success.call(response)
      else
        response
      end
    end

    # Resets the state of the client, clearing the response and completion status.
    def reset_state
      @response = nil
      @complete = false
    end

    # Default configuration for Faraday connection and middleware
    # to be overridden in subclasses.
    def configure_faraday_connection(faraday)
    end
  end
end
