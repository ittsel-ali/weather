# app/controllers/weather/forecasts_controller.rb
module Weather
  class ForecastController < ApplicationController
    include ResponseHelper # Include the response helper for standardized responses

    # Handles weather forecast requests
    #
    # @return [JSON] A structured forecast response
    def index
      query = Forecast.new(permitted_params)

      if query.valid?
        forecast_manager = ForecastManager.new(lat: query.lat, lon: query.lon)
        raw_forecast_data = forecast_manager.lookup_weather_forecast

        # Serialize the raw data using the custom serializer
        serialized_forecast = WeatherForecastSerializer.new(raw_forecast_data).serialize

        render_success(data: serialized_forecast, message: 'Weather forecast fetched successfully')
      else
        render_error(errors: query.errors.full_messages, status: :bad_request)
      end
    rescue StandardError => e
      handle_error(e)
    end

    private

    # Permits and sanitizes request parameters
    #
    # @return [ActionController::Parameters] Permitted parameters
    def permitted_params
      params.permit(:lat, :lon)
    end

    # Handles unexpected errors and renders a standardized error response
    #
    # @param error [Exception] The error to handle
    def handle_error(error)
      Rails.logger.error("[ForecastsController] Error: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n")) if error.backtrace

      render_error(errors: 'An unexpected error occurred. Please try again later.', status: :internal_server_error)
    end
  end
end
