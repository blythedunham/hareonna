# frozen_string_literal: true


# This service fetches the weather forecast for a given location
# using the Visual Crossing API. It uses caching to avoid unnecessary
# API calls and includes logging for debugging purposes.
class WeatherForecastService
  include Utils::LogHelper

  def initialize(location)
    @location = location
    @client = Clients::VisualCrossing::Timeline.new(location: location)
    @cacher = WeatherForecastCacher.new(location)
  end

  # Fetches the weather forecast for the specified location using the cache.
  # The response is memoized to avoid repeated calls (since only zips are cached)
  # @return [WeatherForecast, nil] The weather forecast object or nil on error
  def weather_forecast
    return @weather_forecast if defined?(@weather_forecast)

    @weather_forecast = cacher.fetch { fetch_weather_forecast }
  end

  protected

  attr_reader :client, :cacher

  # Fetches the weather forecast from the Visual Crossing API and parses the response.
  # @return [WeatherForecast, nil] The weather forecast object or nil on error
  def fetch_weather_forecast
    response = client.get

    # The error handling is already done in the client with error logging
    return nil unless response&.success?

    parse_request(response.body)
  end

  # Parses the response from the Visual Crossing API.
  # @param [Hash] payload The response payload from the API.
  # @return [WeatherForecast] The weather forecast object
  def parse_request(payload)
    Parsers::VisualCrossing::WeatherForecast.new(payload).parse
  end
end
