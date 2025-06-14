# frozen_string_literal: true

module Utils
  module LogHelper
    extend ActiveSupport::Concern

    included do
      protected

      # Logs a message with optional error and severity.
      def log(severity: nil, e: nil, **params)
        message = default_log_context.merge(log_context, params)

        if e
          message.merge!(error_class: e.class.name, error_message: e.message)
          severity ||= "error"
        end

        Rails.logger.send(severity || "warn", message.inspect)
        nil
      rescue StandardError => e
        Rails.logger.error "Logging error: #{e.message}"
        nil
      end

      # Method to log the context of the request
      def log_context
        {}
      end

      private
      def default_log_context
        { class: self.class }
      end
    end
  end
end
