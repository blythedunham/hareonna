# frozen_string_literal: true

module Clients
  # client = Clients.VisualCrossing.new(location: 'New York, NY')
  # payload = client.get

  module VisualCrossing
    class Timeline < Clients::Base
      attr_accessor :location

      # Default Faraday options for the Visual Crossing client.
      self.default_connection_options = {
        url: "https://weather.visualcrossing.com",
        params: {
          key: Rails.application.credentials.api_keys.visual_crossing,
          unitGroup: "us" # later this could be made configurable
        }
      }

      # Default path for the Visual Crossing client.
      self.default_path = "/VisualCrossingWebServices/rest/services/timeline"

      def initialize(location:, **options, &block)
        raise ArgumentError, "Location is required" if location.blank?
        super

        @location = location.to_s.strip
      end

      # Fetches weather data for a given location.
      # @param [String] location The location to fetch weather data for.
      # @return [Hash, nil] The weather data if successful, or nil if an error occurs.
      def get
        super(default_path, location: location)
      end

      protected

      # Called by base class to customize the Faraday middleware.
      # @param [Faraday::Connection] faraday - connection instance
      def configure_faraday_connection(faraday)
        faraday.request :json

        # Super important to avoid logging sensitive data like API keys
        faraday.response :logger do | logger |
          logger.filter(/(key=)([^&]+)/, '\1[REMOVED]')
        end
      end

      # @return [Hash] Additional logging context
      def log_context(**params)
        { location: location }
      end
    end
  end
end
