module WeatherForecastsHelper
  # Returns the weather icon image tag for the given icon name.
  # @param icon_name [String] The name of the weather icon (without file extension)
  # @param options [Hash] Additional options for the image tag
  # @return [String] The HTML image tag for the weather icon
  def weather_icon(icon_name, **options)
    image_tag "weather_icons/#{icon_name}.svg", class: "weather-icon", **options
  end

  # Returns the weather icon image tag for the current weather.
  # @param icon_name [String] The name of the weather icon (without file extension)
  # @param options [Hash] Additional options for the image tag
  # @return [String] The HTML image tag for the weather icon
  def current_weather_icon(icon_name, **options)
    weather_icon(icon_name, class: "current weather-icon", **options)
  end

  # Day of week weather formatting for exteneded forecast
  # @param date [Date] The date to format
  # @return [String] The formatted day of the week or "Today" if the date is today
  def dow(date)
    return "Today" if date.today?

    date.strftime("%a")
  end

  # Formats the temperature value with a degree symbol.
  # @param value [Numeric] The temperature value to format
  # @return [String] The formatted temperature string with a degree symbol
  def temperature(value)
    "#{value.to_i} °"
  end
end
