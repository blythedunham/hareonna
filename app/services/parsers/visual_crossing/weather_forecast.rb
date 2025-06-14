# frozen_string_literal: true

module Parsers
  module VisualCrossing
    class WeatherForecast < BaseApiPayload
      self.payload_key_aliases = {
        # latitude: :latitude,
        # longitude: :longitude,
        # description: :description,
        cleaned_location: :resolvedAddress,
        search_terms: :address,
        timezone: :timezone
      }

      protected

      # Parse the payloads for the current weather and extended forecast
      # @return Array<String> - the fields to extract from the JSON payload
      def model_fields
        super.concat([ "current",  "extended_forecast" ])
      end

      # Use the current time since Visual Crossing does not provide a timestamp
      # @return [Time]
      def parse_reported_at
        Time.now
      end

      # Parse the current conditions into a PointForecastParser object
      # @return [VisualCrossing::PointForecast]
      def parse_current
        VisualCrossing::PointForecast.new(json["currentConditions"]).parse
      end

      def parse_extended_forecast
        json["days"].map do |day|
          VisualCrossing::PointForecast.new(day).parse
        end
      end
    end
  end
end
