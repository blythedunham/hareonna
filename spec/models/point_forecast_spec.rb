require 'rails_helper'

RSpec.describe PointForecast, type: :model do
  it { should respond_to(:date_time) }
  it { should respond_to(:temperature) }
  it { should respond_to(:description) }
  it { should respond_to(:conditions) }
  it { should respond_to(:humidity) }
  it { should respond_to(:feels_like_temp) }
  it { should respond_to(:precip) }
  it { should respond_to(:tag) }
  it { should respond_to(:temperature_high) }
  it { should respond_to(:temperature_low) }
  it { should respond_to(:wind_gust) }
  it { should respond_to(:wind_speed) }
  it { should respond_to(:wind_direction) }
end
