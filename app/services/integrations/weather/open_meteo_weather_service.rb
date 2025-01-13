# app/services/integrations/weather/open_meteo_weather_service.rb
module Integrations
  module Weather
    class OpenMeteoWeatherService < BaseWeather
      BASE_URL = 'https://api.open-meteo.com/v1/forecast'.freeze

      attr_accessor :lat, :lon, :request_manager

      # Initializes the service with latitude and longitude
      #
      # @param lat [Float] Latitude of the location
      # @param lon [Float] Longitude of the location
      def initialize(lat, lon, request_manager)
        @lat = lat
        @lon = lon
        @request_manager = request_manager
      end

      # Fetches current weather details and daily forecast
      #
      # @return [Hash] A structured hash containing current weather and forecast details
      def fetch_weather_details
        params = build_query_params
        response = request_manager.get(BASE_URL, params: params)
        process_weather_response(response)
      rescue StandardError => e
        handle_error(e)
      end

      private

      # Builds the query parameters for the Open-Meteo API request
      #
      # @return [Hash] The query parameters
      def build_query_params
        {
          latitude: lat,
          longitude: lon,
          current_weather: true,
          daily: 'temperature_2m_max,temperature_2m_min,weathercode',
          timezone: 'auto'
        }
      end

      # Processes the parsed API response to extract relevant weather details
      #
      # @param data [Hash] The parsed JSON response
      # @return [Hash] A structured hash containing current weather and daily forecast
      def process_weather_response(data)
        current_weather = data['current_weather']
        daily = data['daily']

        {
          current_weather: {
            temperature: current_weather['temperature'],
            wind_speed: current_weather['windspeed'],
            condition: map_weather_code(current_weather['weathercode'])
          },
          daily_forecast: daily['time'].each_with_index.map do |date, index|
            {
              date: date,
              max_temperature: daily['temperature_2m_max'][index],
              min_temperature: daily['temperature_2m_min'][index],
              condition: map_weather_code(daily['weathercode'][index])
            }
          end
        }
      end

      # Handles errors during the API call or response parsing
      #
      # @param error [Exception] The exception to handle
      # @return [nil] Logs the error and raises it for the caller to handle
      def handle_error(error)
        log_error(error)
        raise error
      end
    end
  end
end
