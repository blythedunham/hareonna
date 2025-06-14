# frozen_string_literal: true

class WeatherForecastsController < ApplicationController
  before_action :validate_location

  def show
    @weather_forecast = WeatherForecastService.new(@location).weather_forecast

    # This is rather generic. Improvements would be to handle specific errors
    # from Visual Crossing API and wrap them in user-freindly messages.
    raise StandardError, "Weather forecast not found" unless @weather_forecast

  rescue => e
    render_error error: e
  end

  protected

  DEFAULT_ERROR_MESSAGE = "An error occurred while fetching the weather forecast. Please ensure you have entered a valid location or try again later."

  # Renders an error message and logs the error.
  # @param [StandardError, nil] error The error that occurred, if any
  # @param [String] message The user-friendly error message to display
  def render_error(error: nil, message: DEFAULT_ERROR_MESSAGE)
    @weather_forecast = nil
    log e: error, msg: "An error has occured", user_message: message
    flash.now[:error] = message
    render :show, status: :unprocessable_entity unless performed?
  end

  # Validates the location parameter and sets @location if valid.
  # @return [Boolean] true if valid, false otherwise
  def validate_location
    search_location = SearchLocation.new(location: @location = params[:location])

    if search_location.valid?
      @location = search_location.location
      true
    else
      render_error(message: "Please provide a valid address, city, or zip code with at least 5 characters.")
      false
    end
  end
end
