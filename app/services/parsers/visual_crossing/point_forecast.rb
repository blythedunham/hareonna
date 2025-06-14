# frozen_string_literal: true

module Parsers
  module VisualCrossing
    class PointForecast < Parsers::BaseApiPayload
      self.payload_key_aliases = {
        date_time: :datetime,
        feels_like_temp: :feelslike,
        temperature_high: :tempmax,
        temperature_low: :tempmin,
        precip: :precip,
        tag: :icon,
        temperature: :temp,
        wind_gust: :windgust,
        wind_speed: :windspeed,
        wind_direction: :winddir
        # description: :description,
        # conditions: :conditions,
        # humidity: :humidity,
      }


      protected
      def parse_date_time
        from_epoch(dig("datetimeEpoch"))
      end
    end
  end
end
