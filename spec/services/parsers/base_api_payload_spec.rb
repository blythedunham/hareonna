require 'rails_helper'

class Dummy
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :age, :integer
  attribute :enrolled_at, :datetime
end

class Parsers::Dummy < Parsers::BaseApiPayload
  self.payload_key_aliases = {
    age: :agey
  }
end

# Test for the base API payload parser
RSpec.describe Parsers::BaseApiPayload, type: :service do
  let(:payload) { { name: 'Bob', agey: 42, epoch: 1749685280 } }

  let(:no_model_service) { described_class.new(payload, model_fields: [ :name, :age ]) }

  let(:service) { Parsers::Dummy.new(payload) }
  describe '#initialize' do
    it 'assigns the payload' do
      expect(service.json).to eq(payload.stringify_keys)
    end
  end

  describe '#parse' do
    context 'with dummy subclass' do
      let(:parsed_result) { { "name" => "Bob", "age" => 42, "enrolled_at" => nil } }
      it 'parses the payload' do
        dummy_model = service.parse
        expect(dummy_model).to be_a(Dummy)
        expect(dummy_model.name).to eq('Bob')
        expect(dummy_model.age).to eq(42)
        expect(dummy_model.enrolled_at).to be_nil
      end
    end

    context 'with no subclass' do
      it 'parses the payload without a model' do
        ostruct_model = no_model_service.parse
        expect(ostruct_model).to be_a(OpenStruct)
        expect(ostruct_model.name).to eq('Bob')
        expect(ostruct_model.age).to be_nil
      end
    end
  end

  describe '#dig' do
    it 'returns the value for a given key' do
      expect(service.send(:dig, :name)).to eq('Bob')
      expect(service.send(:dig, :agey)).to eq(42)
    end

    it 'returns nil for a non-existent key' do
      expect(service.send(:dig, :non_existent)).to be_nil
    end
  end

  describe '#from_timestamp' do
    it 'parses string time to Time object' do
      expect(service.send(:from_timestamp, '2025-06-11 16:41:20')).to eq(Time.parse('2025-06-11 16:41:20'))
    end

    it 'returns nil for nil input' do
      expect(service.send(:from_timestamp, nil)).to be_nil
    end

    it 'returns nil for erroneous input' do
      expect(service).to receive(:log)
      .with(
        msg: "Unable to parse time",
        e: instance_of(ArgumentError),
        value: 'blerg'
      )
      expect(service.send(:from_timestamp, 'blerg')).to be_nil
    end
  end

  describe '#from_epoch' do
    it 'converts epoch time to Time object' do
      expect(service.send(:from_epoch, 1749685280)).to eq(Time.at(1749685280))
    end

    it 'returns nil for nil input' do
      expect(service.send(:from_epoch, nil)).to be_nil
    end

    it 'returns nil for erroneous input' do
      expect(service).to receive(:log)
      .with(
        msg: "Unable to parse epoch value",
        e: instance_of(TypeError),
        value: 'blerg'
      )
      expect(service.send(:from_epoch, 'blerg')).to be_nil
    end
  end
end
