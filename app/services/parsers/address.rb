# frozen_string_literal: true

# This class is responsible for parsing addresses to determine if user
# specified locations contain a zip code (and are cacheable).

module Parsers
  class Address
    # For MVP do US zip codes (5-digit or ZIP+4)
    ZIP_REGEX = /\b\d{5}(?:-\d{4})?\b/

    # @param location [String] The address string to parse
    def initialize(location)
      @location = location.to_s.strip
    end

    # @return [Boolean] True if the address has a zip code, otherwise false
    def has_zip_code?
      zip_code.present?
    end

    # @return [String, nil] The zip code if found, otherwise nil
    def zip_code
      return @zip_code if defined?(@zip_code)

      match = @location.match(ZIP_REGEX)
      @zip_code = match && match[0] # Extract the matched zip code
    end
  end
end
