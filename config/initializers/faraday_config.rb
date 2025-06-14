# frozen_string_literal: true

Faraday.default_connection_options = {
  request: {
    # Set default request timeouts (in seconds)
    open_timeout: 1,
    read_timeout: 2,
    write_timeout: 2
  },

  # Set default headers
  headers: {
    "User-Agent" => "hareonna,FaradayClient/1.0",
    "Content-Type" => "application/json"
    # 'Accept' => 'application/json'
  }
}

if Rails.env.test?
  Rails.application.credentials.api_keys = ActiveSupport::OrderedOptions.new
  Rails.application.credentials.api_keys.visual_crossing = "FAKE_API_KEY"
end
