require 'rails_helper'

RSpec.describe SearchLocation, type: :model do
  it { should respond_to(:location) }

  subject { described_class.new(location: '   98122    ') }
  it 'should clean the location before validation' do
    subject.valid?
    expect(subject.location).to eq('98122')
  end

  it 'should not allow blank location' do
    subject.location = '   '
    expect(subject).not_to be_valid
    expect(subject.errors[:location]).to include("can't be blank")
  end
  it 'should not allow location < than 5 characters' do
    subject.location = 'abc'
    expect(subject).not_to be_valid
  end
end
