require 'rails_helper'

RSpec.describe WeatherForecastService do
  let(:location) { 'New York, NY' }
  let(:service) { described_class.new(location) }

  describe '#fetch_weather_forecast' do
    let(:client) { instance_double(Clients::VisualCrossing::Timeline) }
    let(:wf) { instance_double(WeatherForecast) }
    let(:response) { nil }

    before do
      allow(service).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response)
    end

    it 'calls client.get' do
      service.send :fetch_weather_forecast
      expect(client).to have_received(:get)
    end

    context 'with unsuccessful response' do
      it 'returns a WeatherForecast object' do
        expect(service.send(:fetch_weather_forecast)).to be_nil
      end
    end

    context 'with successful response' do
      let(:response) { instance_double(Faraday::Response, body: { 'yay' => '123' }) }

      before do
        allow(service).to receive(:parse_request).and_return(wf)
        allow(response).to receive(:success?).and_return(true)
      end

      it 'returns a WeatherForecast object' do
        expect(service.send(:fetch_weather_forecast)).to eq(wf)
      end

      it 'calls parse_request with response.body' do
        service.send(:fetch_weather_forecast)
        expect(service).to have_received(:parse_request).with(response.body)
      end
    end

    it 'calls parse_request with the response from the client' do
    end
  end


  describe '#weather_forecast' do
    let(:cacher) { instance_double(WeatherForecastCacher) }

    before do
      allow(service).to receive(:cacher).and_return(cacher)
      allow(cacher).to receive(:fetch).and_yield
      allow(service).to receive(:fetch_weather_forecast)
      service.weather_forecast
    end

    it 'calls fetch_weather_forecast' do
      expect(service).to have_received(:fetch_weather_forecast)
    end

    it 'calls cacher.fetch' do
      expect(cacher).to have_received(:fetch)
    end
  end
end
