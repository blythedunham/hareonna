# app/models/weather_forecast.rb

class WeatherForecast
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  # Todo: We would probably want to add some validations here
  attribute :reported_at, :datetime
  attribute :cleaned_location, :string
  attribute :description, :string
  attribute :search_terms, :string
  attribute :timezone, :string
  attribute :latitude, :float
  attribute :longitude, :float
  attribute :cached_result, :boolean, default: false

  attr_accessor :current, :extended_forecast

  def initialize(attributes = {})
    super

    @current = nil
    @extended_forecast = []
  end
end
