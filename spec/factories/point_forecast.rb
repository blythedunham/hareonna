FactoryBot.define do
  factory :point_forecast do
    date_time { Time.current }
    description { 'Sunny and awesome' }
    conditions { 'Sunny' }
    humidity { 0.5 }
    feels_like_temp { 71.0 }
    precip { 0.0 }
    tag { 'clear-day' }
    temperature { 75.0 }
    temperature_high { 78.0 }
    temperature_low { 68.0 }
    wind_gust { 5.0 }
    wind_speed { 3.0 }
    wind_direction { 180.0 } # South
  end
end
