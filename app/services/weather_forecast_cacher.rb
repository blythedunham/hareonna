# frozen_string_literal: true

# This class is responsible for caching WeatherForecast instances
# It includes a parser to determine if it is cacheable (location has a zip code)
#
# The user can enter any type of location (zip code, city name, etc.)
# for ease of use. It can be confusing to have mulitple input boxes.
# This is also faster and avoids having to geocode free form address input
# with an additional API call.
#
# However, for the MVP, we are only caching forecasts when US zip codes
# are specified.
#
# Later improvements could include:
# - Caching by city name (and state or country)
# - Caching by coordinates (lat/lon)
# - Accessing zip code from a location service (an RDS zip table would be ideal to
#   avoid API calls)

class WeatherForecastCacher
  include Utils::LogHelper

  EXPIRES_IN = 30.minutes
  PREFIX = "weather_forecast_"

  def initialize(location)
    @location = location.to_s.strip
    @parser = Parsers::Address.new(@location)
  end

  # Fetches the weather forecast from the cache if available for the location
  # If a block is given, it will be executed to fetch the forecast if not found in cache.
  # @yield [WeatherForecast] The block to execute if the forecast is not found in cache.
  # @return [WeatherForecast, nil] The cached weather forecast or the result of the block.
  def fetch(&block)
    forecast = _fetch
    forecast ||= yield.tap { |f| write(f) } if block_given?
    forecast
  end

  # @param weather_forecast [WeatherForecast] The weather forecast to cache
  # @return [Boolean] True if caching was successful, false otherwise
  #
  # Caches the weather forecast as JSON in Rails.cache with a TTL.
  # Returns true if successful, false if not cacheable or an error occurs.
  def write(weather_forecast, expires_in: EXPIRES_IN)
    return false if weather_forecast.blank?
    return false unless should_cache?

    Rails.cache.write(cache_key, weather_forecast, expires_in: expires_in)
    log msg: "Cached weather forecast"

    true
  rescue => e
    log msg: "Error caching weather forecast", e: e
    false
  end

  protected

  # Determines if the weather forecast should be cached based on location
  # @return [Boolean] True if the location has a zip code, false otherwise
  def should_cache?
     cache_key.present?
  end

  # Fetches the weather forecast from the cache
  # If found, it marks it as cached and logs the event.
  # @return [WeatherForecast, nil] The cached weather forecast or nil if not found
  def _fetch
    unless should_cache?
      log msg: "Will not cache location"
      return nil
    end

    forecast = Rails.cache.fetch(cache_key)

    if forecast.present?
      forecast.cached_result = true
      log msg: "Fetched weather forecast from cache"
    else
      log msg: "Cache miss for weather forecast"
    end

    forecast
  rescue => e
    log msg: "Error fetching weather forecast from cache", e: e
    nil
  end

  # Returns the cache key for the weather forecast based on the location's zip code.
  # If the location does not have a zip code, returns nil.
  # @return [String, nil] The cache key or nil if not cacheable.
  def cache_key
    @cache_key ||= "#{PREFIX}#{@parser.zip_code}" if @parser.has_zip_code?
  end

  # @return [Hash] The additional context for logging
  def log_context
    { location: @location, cache_key: @cache_key }
  end
end
