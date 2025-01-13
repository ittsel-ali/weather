# app/serializers/weather_forecast_serializer.rb
class WeatherForecastSerializer
  def initialize(data)
    @data = data
  end

  # Serializes the weather data into a standardized JSON format
  #
  # @return [Hash] Serialized weather forecast
  def serialize
    {
      current_weather: serialize_current_weather(@data[:current_weather]),
      daily_forecast: serialize_daily_forecast(@data[:daily_forecast])
    }
  end

  private

  # Serializes the current weather data
  #
  # @param current_weather [Hash] Current weather details
  # @return [Hash] Serialized current weather
  def serialize_current_weather(current_weather)
    {
      temperature: current_weather[:temperature],
      wind_speed: current_weather[:wind_speed],
      condition: current_weather[:condition]
    }
  end

  # Serializes the daily forecast data
  #
  # @param daily_forecast [Array<Hash>] Array of daily weather details
  # @return [Array<Hash>] Serialized daily forecast
  def serialize_daily_forecast(daily_forecast)
    daily_forecast.map do |day|
      {
        date: day[:date],
        max_temperature: day[:max_temperature],
        min_temperature: day[:min_temperature],
        condition: day[:condition]
      }
    end
  end
end
