FactoryBot.define do
  factory :weather_forecast do
    reported_at { Time.current }
    cleaned_location { 'Seattle, WA' }
    description { 'Sunny with a chance of rain' }
    search_terms { '98122' }
    timezone { 'America/Los_Angeles' }
    latitude { 47.6062 }
    longitude { -122.3321 }

    association :current, factory: :point_forecast
    association :extended_forecast, factory: :point_forecast

    after(:build) do |forecast, evaluator|
      forecast.current = build(:point_forecast)
      forecast.extended_forecast = [
        build(
        :point_forecast,
        temperature: 68.0,
        tag: 'rain',
        precip: 80,
        conditions: 'rainy',
        date_time: Time.current + 1.day,
        temperature_high: 68.0,
        temperature_low: 62.0

        ),
        build(
          :point_forecast,
          temperature: 70.0,
          tag: 'partly-cloudy-day',
          precip: 10,
          conditions: 'partly cloudy',
          date_time: Time.current + 1.day,
          temperature_high: 70.0,
          temperature_low: 66.0
        )
    ]
    end
  end
end
