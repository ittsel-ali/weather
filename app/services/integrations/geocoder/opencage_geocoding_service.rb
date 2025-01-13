module Integrations
  module Geocoder
    class OpencageGeocodingService
      GEOCODE_DATA_LIMIT = 5.freeze # Restricts the count of query results
      BASE_URL = 'https://api.opencagedata.com/geocode/v1/json'.freeze

      attr_accessor :api_key, :request_manager 
      
      # Initializes the service with an API key
      #
      # @param api_key [String] The API key for OpenCage Geocoder API
      def initialize(api_key = ENV['OPENCAGE_API_KEY'])
        @api_key = api_key
        @request_manager = RequestManager
      end

      # Fetches geocoding data for a given query
      #
      # @param query [String] The address or place to search
      # @param options [Hash] Additional query parameters (e.g., language, countrycode)
      # @return [Array<Hash>] List of geocoding results with addresses and coordinates
      def fetch_geocoding_data(query, options = {})
        handle_errors_as_array do
          validate_query!(query)

          params = build_params(query, options)
          response = request_manager.get(BASE_URL, params: params)

          process_response(response)
        end
      end

      private

      # Handles errors and ensures an array is always returned
      #
      # @yield [Array<Hash>] The block containing the logic to execute
      # @return [Array<Hash>] The result of the block or an empty array on failure
      def handle_errors_as_array
        yield
      rescue ArgumentError => e
        log_error("Validation Error: #{e.message}", context: 'fetch_geocoding_data')
        []
      rescue StandardError => e
        log_error("Service Error: #{e.message}", context: 'fetch_geocoding_data', backtrace: e.backtrace)
        []
      end

      # Validates the query input
      #
      # @param query [String] The query string to validate
      # @raise [ArgumentError] If the query is blank
      def validate_query!(query)
        raise ArgumentError, 'Query cannot be blank' if query.strip.empty?
      end

      # Builds query parameters for the API request
      #
      # @param query [String] The user's input query
      # @param options [Hash] Additional options for the API call
      # @return [Hash] Constructed query parameters
      def build_params(query, options)
        { q: query, key: api_key, limit: GEOCODE_DATA_LIMIT }.merge(options)
      end

      # Processes the API response
      #
      # @param response [Hash, nil] The API response to process
      # @return [Array<Hash>] List of results with full addresses and coordinates
      def process_response(response)
        if response && response['results'].any?
          response['results'].map { |result| parse_result(result) }
        else
          []
        end
      end

      # Parses a single result from the API response
      #
      # @param result [Hash] A single result from the API response
      # @return [Hash] Parsed data containing address and coordinates
      def parse_result(result)
        location = result['geometry']
        {
          full_address: result['formatted'],
          lat: location['lat'],
          lng: location['lng']
        }
      end

      # Logs an error message with additional context
      #
      # @param message [String] The error message to log
      # @param context [String] Additional context for the log entry
      # @param backtrace [Array<String>, nil] The error backtrace (optional)
      def log_error(message, context:, backtrace: nil)
        Rails.logger.error("[#{context}] #{message}")
        Rails.logger.error(backtrace.join("\n")) if backtrace
      end
    end
  end
end
