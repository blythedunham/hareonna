# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clients::VisualCrossing::Timeline do
  include_context 'with VisualCrossing response'
  # vc_json_data is a sample JSON for a valid response

  let(:location) { '98122' }
  let(:service) { described_class.new(location:) }
  let(:response_json) { { status: 200, body: vc_json_data.to_json } }

  before do
    stub_request(:get, /visualcrossing.com/).to_return(response_json)
  end

  describe '#initialize'  do
    it 'raises an error if location is not provided' do
      expect { described_class.new(location: nil) }.to raise_error(ArgumentError, "Location is required")
    end
  end

  describe '#get' do
    it 'calls the Visual Crossing API and returns parsed data' do
      response = service.get
      expect(response).to be_a(Faraday::Response)
      expect(response.success?).to be_truthy
      expect(service.response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq(vc_json_data)
    end

    context 'when the API call fails' do
      let(:response_json) { { status: 400, body: 'Doh!' } }
      before do
        service.send :get
      end

      it 'creates a response with error status codes' do
        expect(service.response.status).to eq(400)
        expect(service.response.success?).to be_falsy
      end
    end
  end
end
