# frozen_string_literal: true

require "ostruct"

# This class is a base class for parsing API payloads.
# It provides a structure to parse JSON payloads into a model object
# Subclasses should define custom parsing logic for different fields.
module Parsers
  class BaseApiPayload
    include Utils::LogHelper

    # Mapping of object field names to key names in the JSON payload
    # # Example:
    #
    # self.payload_key_aliases = {
    #   temperature: :temp, # The object field `temperature` will be set to json['temp']
    # }
    class_attribute :payload_key_aliases, default: {}
    self.payload_key_aliases = {}

    attr_accessor :json, :options

    # Initializes the parser with a raw JSON payload and options
    # @param raw_json [String, Hash] The raw JSON payload to parse
    # @param options [Hash] Additional options for parsing, such as model_class and model_fields
    # @option options [String, Class] :model_class The class to use for the model
    # @option options [Array<String>] :model_fields The fields to be parsed from the model
    # @raise [ArgumentError] if model_fields are not provided and the model does not respond to attribute_names
    # @raise [ArgumentError] if model_fields are blank
    def initialize(raw_json, **options)
      @json = raw_json.is_a?(String) ? JSON.parse(raw_json) : raw_json.stringify_keys
      @options = options
      @model = model_class.new

      @model.original_payload = raw_json if @model.respond_to?(:original_payload)
    end

    # Parses the JSON payload and populates the model instance with values
    # @return [Object] - The model instance populated with parsed values
    def parse
      model_fields.each do |field|
        @model.send("#{field}=", parse_value(field))
      end
      @model
    end

    protected

    # @return [Hash] The keys to use to dig through the payload
    def dig(*args)
      json.dig(*args.map(&:to_s))
    end

    # @return [String] The name of the key in the payload
    # with data used to populate the model field
    def key_for_field(field)
      (payload_key_aliases[field.to_sym] || field).to_s
    end

    # Parses the value for a given field from the JSON payload
    # If a special method named parse_<field> is implemented, it will be called
    # Otherwise, it will return the value from the JSON payload using the key
    # defined in payload_key_aliases or the field name itself
    #
    # @param field [Symbol,String] The field to parse
    # @return [Object] The parsed value for the field
    # @raise [NoMethodError] if the parse_<field> method is not defined
    def parse_value(field)
      # If a special method named parse_<field> if implemented
      return send("parse_#{field}") if methods.include?("parse_#{field}".to_sym)

      # Return the value in the json payload
      dig(key_for_field(field))
    end

    # Helper to parse a Time from epoch
    # @param value [Integer, String] The value to parse
    # @return [Time, nil] The parsed Time object or nil if parsing fails
    def from_epoch(value)
      Time.at(value) if value
    rescue => e
      log msg: "Unable to parse epoch value", e: e, value: value
      nil
    end

    # Helper to parse a Time from a timestamp
    # @param value [Integer, String] The value to parse
    # @return [Time, nil] The parsed Time object or nil if parsing fails
    def from_timestamp(value)
      Time.parse(value) if value
    rescue => e
      log msg: "Unable to parse time", e: e, value: value
      nil
    end

    # @return [OpenStruct, Class] The class to use for the model
    # This is inferred from the class name or OpenStruct for the base class
    def model_class
      return @options[:model_class].constantize if @options[:model_class].present?

      class_name = self.class.name.demodulize
      class_name == "BaseApiPayload" ? OpenStruct : class_name.constantize
    end

    # @return [Array<String>] The fields to be parsed from the model
    # If not provided as options[:model_fields], the model's attribute names
    # are used
    def model_fields
      return @options[:model_fields].map(&:to_s) if @options[:model_fields].present?
      return @model.attribute_names if @model.respond_to?(:attribute_names)

      raise ArgumentError, "model fields cannot be blank"
    end
  end
end
