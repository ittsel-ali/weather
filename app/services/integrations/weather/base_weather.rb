# frozen_string_literal: true

# app/services/integrations/weather/base_weather_service.rb
module Integrations
  module Weather
    # Provides shared functionality for weather services
    # Includes mapping weather codes to conditions and error logging.
    class BaseWeather
      # Weather code to condition mapping
      WEATHER_CODE_MAP = {
        0 => 'Clear',
        1 => 'Partly Cloudy', 2 => 'Partly Cloudy', 3 => 'Partly Cloudy',
        45 => 'Fog', 48 => 'Fog',
        51 => 'Drizzle', 53 => 'Drizzle', 55 => 'Drizzle',
        61 => 'Rain', 63 => 'Rain', 65 => 'Rain',
        71 => 'Snow', 73 => 'Snow', 75 => 'Snow',
        95 => 'Thunderstorm',
        96 => 'Thunderstorm with Hail', 99 => 'Thunderstorm with Hail'
      }.freeze

      # Maps the weather code to a human-readable condition
      #
      # @param weather_code [Integer] The weather code from the API
      # @return [String] The corresponding condition (e.g., "Clear", "Rainy")
      def map_weather_code(weather_code)
        WEATHER_CODE_MAP[weather_code] || 'Unknown'
      end

      # Logs an error message
      #
      # @param error [Exception] The exception to log
      def log_error(error)
        Rails.logger.error("[#{self.class.name}] Error: #{error.message}")
        Rails.logger.error(error.backtrace.join("\n")) if error.backtrace
      end
    end
  end
end
