# frozen_string_literal: true

# app/services/weather/forecast_manager.rb
module Weather
  # Manages weather data retrieval with caching and error handling, using an external weather service.
  class ForecastManager
    CACHE_KEY_PREFIX = 'WeatherForecast'
    CACHE_EXPIRATION = 30 * 60 # Cache expiry to 30 minutes

    attr_accessor :cache_manager, :weather_service

    # Initializes the WeatherManager with a CacheManager and a WeatherService
    #
    # @param cache_manager [CacheManager] The caching manager instance
    # @param weather_service [OpenMeteoWeatherService] The weather service instance
    def initialize(lat:, lon:)
      @cache_manager = CacheManager.new(
        CACHE_POOL,
        key_prefix: CACHE_KEY_PREFIX,
        expiration: CACHE_EXPIRATION
      )

      @weather_service = Integrations::Weather::OpenMeteoWeatherService.new(
        lat,
        lon,
        RequestManager
      )
    end

    # Fetches weather data with caching
    #
    # @return [Hash] The weather data, either from cache or fetched fresh
    def lookup_weather_forecast
      cache_key = generate_cache_key(weather_service.lat, weather_service.lon)

      cache_manager.fetch(cache_key) do
        weather_service.fetch_weather_details
      end
    rescue StandardError => e
      handle_error(e)
    end

    private

    # Generates a unique cache key for the weather request
    #
    # @param lat [Float] Latitude of the location
    # @param lon [Float] Longitude of the location
    # @return [String] A hashed cache key
    def generate_cache_key(lat, lon)
      cache_manager.generate_key("#{lat},#{lon}")
    end

    # Handles errors and logs them
    #
    # @param error [Exception] The error to handle
    def handle_error(error)
      Rails.logger.error("[WeatherManager] Error: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n")) if error.backtrace
      raise error
    end
  end
end
