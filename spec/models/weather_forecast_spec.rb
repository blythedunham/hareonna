require 'rails_helper'

RSpec.describe WeatherForecast, type: :model do
  it { should respond_to(:reported_at) }
  it { should respond_to(:cleaned_location) }
  it { should respond_to(:extended_forecast) }
  it { should respond_to(:description) }
  it { should respond_to(:search_terms) }
  it { should respond_to(:timezone) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:cached_result) }
  it { should be_a_kind_of(ActiveModel::Model) }
  it { should be_a_kind_of(ActiveModel::Attributes) }
  it { should be_a_kind_of(ActiveModel::AttributeAssignment) }
  it { should respond_to(:current) }
  it { should respond_to(:extended_forecast) }
end
