require 'rails_helper'

RSpec.describe "WeatherForecasts", type: :request do
  let(:wf_service) { instance_double(WeatherForecastService) }
  let(:weather_forecast) { FactoryBot.build(:weather_forecast) }

  before do
    allow(WeatherForecastService).to receive(:new).and_return(wf_service)
    allow(wf_service).to receive(:weather_forecast).and_return(weather_forecast)
    stub_request(:get, /visualcrossing.com/)
  end

  describe "GET /show" do
    it "returns error if no location is provided" do
      get "/weather_forecasts"
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Ut oh!")
    end

    context "when valid location is provided" do
      before { get "/weather_forecasts", params: { location: "98122" } }
      it "renders partial templates on success" do
        expect(response.body).to include("Current Conditions")
        expect(response.body).to include("Extended Forecast")
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
  end
  end
end
