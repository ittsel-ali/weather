# frozen_string_literal: true

# app/controllers/weather/forecasts_controller.rb
module Weather
  # Handles weather forecast requests by validating input, retrieving forecast data via a manager,
  # and serializing the response for the client.
  class ForecastController < ApplicationController
    include ResponseHelper # Include the response helper for standardized responses

    # Handles weather forecast requests
    #
    # @return [JSON] A structured forecast response
    def index
      query = Forecast.new(permitted_params)

      if query.valid?
        render_forecast(query)
      else
        render_validation_errors(query)
      end
    rescue StandardError => e
      handle_error(e)
    end

    private

    # Renders the weather forecast on valid input
    #
    # @param query [Forecast] Validated forecast query object
    def render_forecast(query)
      raw_forecast_data = fetch_forecast_data(query)
      serialized_forecast = serialize_forecast(raw_forecast_data)

      render_success(data: serialized_forecast, message: 'Weather forecast fetched successfully')
    end

    # Renders validation errors for invalid input
    #
    # @param query [Forecast] Query object with validation errors
    def render_validation_errors(query)
      render_error(errors: query.errors.full_messages, status: :bad_request)
    end

    # Fetches forecast data from the ForecastManager
    #
    # @param query [Forecast] Validated forecast query object
    # @return [Hash] Raw weather forecast data
    def fetch_forecast_data(query)
      ForecastManager.new(lat: query.lat, lon: query.lon).lookup_weather_forecast
    end

    # Serializes the forecast data for the response
    #
    # @param raw_forecast_data [Hash] Raw weather forecast data
    # @return [Hash] Serialized forecast data
    def serialize_forecast(raw_forecast_data)
      WeatherForecastSerializer.new(raw_forecast_data).serialize
    end

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
