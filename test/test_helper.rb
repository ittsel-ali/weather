# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'
require 'webmock/minitest'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # rubocop:disable Metrics/MethodLength
    def mock_open_meteo_api
      # Mock forecast data
      forecast_data = {
        current_weather: {
          temperature: 15.2,
          windspeed: 5.4,
          weathercode: 1
        },
        daily: {
          time: %w[2025-01-10 2025-01-11],
          temperature_2m_max: [16.0, 18.0],
          temperature_2m_min: [10.0, 11.0],
          weathercode: [0, 61]
        }
      }.to_json

      # Stub the request
      stub_request(:get, 'https://api.open-meteo.com/v1/forecast')
        .with(
          query: {
            current_weather: true,
            daily: 'temperature_2m_max,temperature_2m_min,weathercode',
            latitude: 37.7749,
            longitude: -122.4194,
            timezone: 'auto'
          }

        )
        .to_return(
          status: 200,
          body: forecast_data,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    def mock_open_cage_geocoder_api
      geocoder_results = [
        {
          formatted: 'Mountain View, CA, USA',
          geometry: {
            lat: 37.3860517,
            lng: -122.0838511
          }
        },
        {
          formatted: 'Mountain Home, ID, USA',
          geometry: {
            lat: 43.132576,
            lng: -115.691198
          }
        }
      ].freeze

      stub_request(:get, %r{https://api.opencagedata.com/geocode/v1/json\?.*limit=5&q=Mountain%20View.*})
        .to_return(status: 200, body: { results: geocoder_results }.to_json, headers: {})
    end
    # rubocop:enable Metrics/MethodLength
  end
end
