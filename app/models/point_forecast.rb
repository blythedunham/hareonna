
# This file defines the PointForecast model, which represents a weather forecast
# for a specific point in time, including attributes like date, description, and temperature.
class PointForecast
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  # Define attributes for ActiveModel
  attribute :date_time, :datetime
  attribute :description, :string
  attribute :conditions, :string
  attribute :humidity, :float
  attribute :feels_like_temp, :float
  attribute :precip, :integer
  attribute :tag, :string
  attribute :temperature, :float
  attribute :temperature_high, :float
  attribute :temperature_low, :float
  attribute :wind_gust, :float
  attribute :wind_speed, :float
  attribute :wind_direction, :float
end
