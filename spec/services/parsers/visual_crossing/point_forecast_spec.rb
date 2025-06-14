require 'rails_helper'

RSpec.describe Parsers::VisualCrossing::PointForecast do
  include_context 'with VisualCrossing response'

  let(:json) { vc_json_data['currentConditions'] }

  # "datetime": "17:42:00",
  # "datetimeEpoch": 1749688920,
  # "temp": 69.1,
  # "feelslike": 69.1,
  # "humidity": 57.6,
  # "dew": 53.5,
  # "precip": 0,
  # "precipprob": 0,
  # "snow": 0,
  # "snowdepth": 0,
  # "preciptype": null,
  # "windgust": 12.9,
  # "windspeed": 8.9,
  # "winddir": 136,
  # "pressure": 1015,
  # "visibility": 9.9,
  # "cloudcover": 0,
  # "solarradiation": 333,
  # "solarenergy": 1.2,
  # "uvindex": 3,
  # "conditions": "Clear",
  # "icon": "clear-day",

  subject(:parser) { described_class.new(json) }

  describe '#parse' do
    it 'returns a PointForecast instance' do
      forecast = parser.parse
      expect(forecast).to be_an(PointForecast)

      expect(forecast.date_time).to eq(Time.at(1749688920))
      expect(forecast.temperature).to eq(69.1)
      expect(forecast.feels_like_temp).to eq(69.1)
      expect(forecast.humidity).to eq(57.6)
      expect(forecast.precip).to eq(0)
      expect(forecast.wind_gust).to eq(12.9)
      expect(forecast.wind_speed).to eq(8.9)
      expect(forecast.wind_direction).to eq(136)
      expect(forecast.tag).to eq('clear-day')
      expect(forecast.conditions).to eq('Clear')
      expect(forecast.description).to be_nil
      expect(forecast.temperature_high).to be_nil
      expect(forecast.temperature_low).to be_nil
    end
  end

  describe '#parse_date_time' do
    it 'returns the latitude from the data' do
      expect(parser.send(:parse_date_time)).to eq(Time.at(1749688920))
    end
  end
end
