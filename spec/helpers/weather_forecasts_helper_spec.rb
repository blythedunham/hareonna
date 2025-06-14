require 'rails_helper'

# Specs for WeatherForecastsHelper
RSpec.describe WeatherForecastsHelper, type: :helper do
  describe '#weather_icon' do
    it 'returns an image tag with the correct src and class' do
      expect(helper.weather_icon('clear-day')).to include('img')
      expect(helper.weather_icon('clear-day')).to include('weather_icons/clear-day')
      expect(helper.weather_icon('clear-day')).to include('class="weather-icon"')
    end

    it 'merges additional options into the image tag' do
      html = helper.weather_icon('rain', alt: 'Rainy', id: 'rain-icon')
      expect(html).to include('alt="Rainy"')
      expect(html).to include('id="rain-icon"')
    end
  end

  describe '#current_weather_icon' do
    it 'returns an image tag with the correct classes' do
      html = helper.current_weather_icon('snow')
      expect(html).to include('class="current weather-icon"')
      expect(html).to include('weather_icons/snow')
    end

    it 'merges additional options into the image tag' do
      html = helper.current_weather_icon('cloudy', alt: 'Cloudy')
      expect(html).to include('alt="Cloudy"')
    end
  end

  describe '#dow' do
    let(:cur_time) { Time.current }
    it 'returns "Today" if the date is today' do
      allow(Time).to receive(:now).and_return(cur_time)
      expect(helper.dow(cur_time)).to eq('Today')
    end

    it 'returns abbreviated day of week for other dates' do
      date = Date.parse('2024-06-01') # Assume not today
      expect(helper.dow(date)).to eq(date.strftime('%a'))
    end
  end

  describe '#temperature' do
    it 'formats integer temperature values with degree symbol' do
      expect(helper.temperature(72)).to eq('72 °')
    end

    it 'formats float temperature values as integer with degree symbol' do
      expect(helper.temperature(72.9)).to eq('72 °')
    end

    it 'formats negative temperature values' do
      expect(helper.temperature(-5)).to eq('-5 °')
    end
  end
end
