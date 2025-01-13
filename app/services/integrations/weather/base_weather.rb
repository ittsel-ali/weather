# app/services/integrations/weather/base_weather_service.rb
module Integrations
  module Weather
    class BaseWeather
      # Maps the weather code to a human-readable condition
      #
      # @param weather_code [Integer] The weather code from the API
      # @return [String] The corresponding condition (e.g., "Clear", "Rainy")
      def map_weather_code(weather_code)
        case weather_code
        when 0 then 'Clear'
        when 1, 2, 3 then 'Partly Cloudy'
        when 45, 48 then 'Fog'
        when 51, 53, 55 then 'Drizzle'
        when 61, 63, 65 then 'Rain'
        when 71, 73, 75 then 'Snow'
        when 95 then 'Thunderstorm'
        when 96, 99 then 'Thunderstorm with Hail'
        else 'Unknown'
        end
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
