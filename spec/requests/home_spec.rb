require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end

    it "renders the home page" do
      get "/"
      expect(response.body).to include("Weather by Hareonna")
      expect(response.body).to include("晴れ女")
    end

    it "includes a search form" do
      get "/"
      expect(response.body).to include("form")
      expect(response.body).to include("input type=\"submit\"")
    end
  end
end
