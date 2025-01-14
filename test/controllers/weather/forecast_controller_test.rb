# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

module Weather
  class ForecastControllerTest < ActionDispatch::IntegrationTest
    setup do
      @valid_params = { lat: '37.7749', lon: '-122.4194' }
      @invalid_params = { lat: '', lon: '' }

      # Call the mock setup for Open Meteo API service
      # Should be a seperate file under mocks/ folder
      mock_open_meteo_api

      @serialized_forecast = {
        current_weather: {
          temperature: 15.2,
          wind_speed: 5.4,
          condition: 'Partly Cloudy'
        },
        daily_forecast: [
          { date: '2025-01-10', max_temperature: 16.0, min_temperature: 10.0, condition: 'Clear' },
          { date: '2025-01-11', max_temperature: 18.0, min_temperature: 11.0, condition: 'Rain' }
        ]
      }
    end

    test 'should return weather forecast with valid parameters' do
      get '/weather/forecast', params: @valid_params

      assert_response :success
      json_response = JSON.parse(response.body, symbolize_names: true)
      assert json_response[:success]
      assert_equal @serialized_forecast, json_response[:data]
      assert_equal 'Weather forecast fetched successfully', json_response[:message]
    end

    test 'should return validation errors with invalid parameters' do
      get '/weather/forecast', params: @invalid_params

      assert_response :bad_request
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], "Lat can't be blank"
      assert_includes json_response[:errors], "Lon can't be blank"
    end

    test 'should return validation errors with out-of-bound parameters (latitude > 90)' do
      get '/weather/forecast', params: { lat: '100', lon: '-122.4194' }

      assert_response :bad_request
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], 'Lat must be less than or equal to 90'
    end

    test 'should return validation errors with out-of-bound parameters (latitude < -90)' do
      get '/weather/forecast', params: { lat: '-100', lon: '-122.4194' }

      assert_response :bad_request
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], 'Lat must be greater than or equal to -90'
    end

    test 'should return validation errors with out-of-bound parameters (longitude > 180)' do
      get '/weather/forecast', params: { lat: '37.7749', lon: '200' }

      assert_response :bad_request
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], 'Lon must be less than or equal to 180'
    end

    test 'should return validation errors with out-of-bound parameters (longitude < -180)' do
      get '/weather/forecast', params: { lat: '37.7749', lon: '-200' }

      assert_response :bad_request
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], 'Lon must be greater than or equal to -180'
    end

    test 'should handle unexpected errors gracefully' do
      ::Weather::ForecastManager.any_instance.stubs(:lookup_weather_forecast).raises(StandardError, 'Unexpected error')

      get '/weather/forecast', params: @valid_params

      assert_response :internal_server_error
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], 'An unexpected error occurred. Please try again later.'
    end
  end
end
