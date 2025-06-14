require 'rails_helper'

RSpec.describe WeatherForecastCacher do
  let(:location) { '98122' }
  let(:wf) { build(:weather_forecast, cleaned_location: location) }

  let(:cacher) { described_class.new(location) }

  describe '#write' do
    context 'when should_cache? returns false' do
      let(:location) { 'Seattle, WA' }

      it 'does not write to the cache' do
        expect(cacher.write(wf)).to be_falsey
      end
    end

    context 'when should_cache? returns true' do
      before do
        allow(Rails.cache).to receive(:write)
      end
      it 'writes the forecast data to the cache' do
        cacher.write(wf)
        expect(Rails.cache).to have_received(:write)
          .with('weather_forecast_98122', wf, expires_in: described_class::EXPIRES_IN)
      end

      it 'returns true after writing to the cache' do
        expect(cacher.write(wf)).to be_truthy
      end
    end
  end

  describe '#fetch' do
    context 'when should_cache? returns false' do
      let(:location) { 'Seattle, WA' }

      it 'does not write to the cache' do
        expect(cacher.fetch).to be_nil
      end

      context 'with block' do
        it 'executes and returns the block' do
          expect(cacher.fetch { wf }).to eq(wf)
        end
      end
    end

    context 'without block' do
      it 'returns nil if no block is given' do
        expect(cacher.fetch).to be_nil
      end
    end

    context 'with block' do
      before { allow(cacher).to receive(:write) }
      it 'yields the block ' do
        expect(cacher.fetch { wf }).to eq(wf)
      end
      it 'caches the result' do
        cacher.fetch { wf }
        expect(cacher).to have_received(:write).with(wf)
      end
    end
  end
end
