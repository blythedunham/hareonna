# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Clients::Base do
  let(:url) { 'http://apple.com' }
  let(:connection_options) { { url: } }
  let(:service) { described_class.new(connection_options:) }
  let(:response_data) { { status: 200, body: 'OK' } }

  before do
    stub_request(:get, /apple.com/).to_return(response_data)
  end

  describe '#initialize'  do
    it "creates a Faraday connection" do
      expect(Faraday).to receive(:new).with({ url: url }).and_call_original
      expect(service.connection).to be_a(Faraday::Connection)
    end
  end

  describe '#get' do
    it 'calls the Visual Crossing API and returns parsed data' do
      response = service.get
      expect(response).to be_a(Faraday::Response)
      expect(response.success?).to be_truthy
      expect(service.response.status).to eq(200)
      expect(response.body).to eq(response_data[:body])
    end

    it 'calls handle_response' do
      expect(service).to receive(:handle_response).and_call_original
      service.get
    end

    context 'when the API call fails' do
      let(:response_data) { { status: 400, body: 'Doh!' } }

      it 'creates a response with error status codes' do
        service.send :get
        expect(service.response.status).to eq(400)
        expect(service.response.success?).to be_falsy
      end
    end
  end
end
