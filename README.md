# README

A hare-onna (晴れ女) is a lucky, sunny lady who brings good weather whereever she goes. This project uses the [Visual Crossing API](https://www.visualcrossing.com/) to show the current weather and day forecast for any address, city or zipcode. It caches with `Rails.cache` if a zip is provided. Hopefully, using it will bring good luck and sunshine.


- Ruby 3.4.4
- Rails 8.0.2

`bundle install`
`bundle exec rspec`

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


# About
In short, the implementation prioritized ease of use for the user inputing any location text. The visual crossing api was selected because it avoids the overhead of a second API call to geocode a location into lat/lng coordinates in order to get the weather (new Google weather, weather.gov, etc). It also returns both the current weather and day by day forecast in one payload. The Faraday Gem is used for the API calls.

Standard issue Rails controllers, views, etc are used (as I ran out of time to build a nice React UI and pretty styling). The backend focuses primarily on decomposition with some inheritance, and the `WeatherForecastSerice` acts as the backend maestro to:
* instantiate a `WeatherForecastCacher` to check the `Rails.cache` (`Redis` would be preferred if time. Also should probably have used action caching in hindsight. )
* Call a `Client::VisualCrossing::Timeline` subclassed from a generic Faraday wrapper client.
* Call a parser to convert the response into `ActiveModel` instances passed back to the controller.


## Classes

### Models
* `WeatherForecast` - `ActiveModel` (not DB persisted) storing weather data for use by FE. 
* `PointForecast` - a subclass of `WeatherForecast` with the current weather or that for a specific time period.

### Services
* `WeatherForecastService` - main service for making the api call, caching, parsing and returning Weather objects
* `WeatherForecastCacher` - responsible for caching `WeatherForcast` objects on top of `Rails.cache`
* `Clients::Base` - Base wrapper for Faraday API requests. Adds consistent logging and common configuration. This makes it easy to make other API request such as a backup.
* `Clients::VisualCrossing::Timeline` - makes API requests to Visual Crossing "timeline" API to get the current weather
* `Parsers::Address` - util to determine if a zip code is present in the address entered by the user
* `Parsers::VisualCrossing::WeatherForecast` - parsers the payload from the `Clients::VisualCrossing::Timeline` into a `WeatherForecast` model
* `Parsers::VisualCrossing::PointForecast`- parses the portion of the weather forecast payload representing a `PointForecast`
* `Utils::LogHelper` - module included on classes to log consistent key/value pairs accross the app

### Controllers
* `WeatherForecastController` - main controller