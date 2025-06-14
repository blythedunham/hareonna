require 'rails_helper'
RSpec.describe Parsers::VisualCrossing::WeatherForecast do
  include_context 'with VisualCrossing response'

  let(:json) { vc_json_data }
  let(:cur_time) { Time.at(1749692219) }
  let(:point_parser) { instance_double("PointForecastParser") }

  # Relevant attributes from the JSON file
  # "latitude": 47.61157,
  # "longitude": -122.30406,
  # "resolvedAddress": "98122, USA",
  # "address": "98122",
  # "timezone": "America/Los_Angeles",
  # "tzoffset": -7,
  # "description": "Similar temperatures continuing with no rain expected.",
  # "days": [

  subject(:parser) { described_class.new(json) }

  before { allow(Time).to receive(:now).and_return(cur_time) }

  describe '#parse' do
    let(:forecast) { parser.parse }

    it 'returns a WeatherForecast instance' do
      expect(forecast).to be_an_instance_of(::WeatherForecast)
    end

    it 'parses the attributes correctly' do
      expect(forecast.attributes).to include(
        "cleaned_location" => "98122, USA",
        "description" => "Similar temperatures continuing with no rain expected.",
        "latitude" => 47.61157,
        "longitude" => -122.30406,
        "reported_at" => Time.at(1749692219),
        "search_terms" => "98122",
        "timezone" => "America/Los_Angeles"
      )
    end
  end

  describe '#parse_reported_at' do
    it 'returns the current time' do
      expect(subject.send(:parse_reported_at)).to eq(cur_time)
    end
  end

  describe '#parse_current' do
    it 'parses the current conditions using PointForecastParser' do
      expect(Parsers::VisualCrossing::PointForecast)
        .to receive(:new).with(vc_json_data["currentConditions"]).and_return(point_parser)
      expect(point_parser).to receive(:parse)
      subject.send :parse_current
    end
  end


  describe '#parse_extended_forecast' do
    it 'parses the current conditions using PointForecastParser' do
      allow(Parsers::VisualCrossing::PointForecast).to receive(:new).and_return(point_parser)
      allow(point_parser).to receive(:parse)

      subject.send :parse_extended_forecast
      expect(point_parser).to have_received(:parse).exactly(vc_json_data["days"].count).times

      vc_json_data["days"].each do |day|
        expect(Parsers::VisualCrossing::PointForecast).to have_received(:new).with(day)
      end
    end
  end
end
