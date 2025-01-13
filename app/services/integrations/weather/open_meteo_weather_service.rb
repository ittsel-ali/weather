# frozen_string_literal: true

# app/services/integrations/weather/open_meteo_weather_service.rb
module Integrations
  module Weather
    # Integrates with the Open-Meteo API to fetch current weather and daily forecasts
    # With error handling and response processing.
    class OpenMeteoWeatherService < BaseWeather
      BASE_URL = 'https://api.open-meteo.com/v1/forecast'

      attr_accessor :lat, :lon, :request_manager

      # Initializes the service with latitude and longitude
      #
      # @param lat [Float] Latitude of the location
      # @param lon [Float] Longitude of the location
      def initialize(lat, lon, request_manager)
        super() # Ensure any initialization logic in the parent class is executed
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
        {
          current_weather: extract_current_weather(data['current_weather']),
          daily_forecast: extract_daily_forecast(data['daily'])
        }
      end

      # Extracts current weather details from the response
      #
      # @param current_weather [Hash] The current weather section of the API response
      # @return [Hash] A structured hash containing temperature, wind speed, and condition
      def extract_current_weather(current_weather)
        {
          temperature: current_weather['temperature'],
          wind_speed: current_weather['windspeed'],
          condition: map_weather_code(current_weather['weathercode'])
        }
      end

      # Extracts the daily forecast from the response
      #
      # @param daily [Hash] The daily section of the API response
      # @return [Array<Hash>] An array of hashes containing forecast details for each day
      def extract_daily_forecast(daily)
        daily['time'].each_with_index.map do |date, index|
          {
            date: date,
            max_temperature: daily['temperature_2m_max'][index],
            min_temperature: daily['temperature_2m_min'][index],
            condition: map_weather_code(daily['weathercode'][index])
          }
        end
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
