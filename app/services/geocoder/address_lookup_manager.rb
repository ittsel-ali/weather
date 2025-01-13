module Geocoder
  class AddressLookupManager
    CACHE_KEY_PREFIX = "Geocoding"

    def initialize
      @geocoding_service = Integrations::Geocoder::OpencageGeocodingService.new
      @cache_manager = CacheManager.new(CACHE_POOL, key_prefix: CACHE_KEY_PREFIX)
    end

    # Fetches address details with caching
    #
    # @param query [String] The address or place to look up
    # @param options [Hash] Additional query parameters (e.g., language, countrycode)
    # @return [Array<Hash>] List of geocoding results with addresses and coordinates, or an empty array in case of errors
    def lookup_address(query, options = {})
      validate_query(query)

      cache_key = @cache_manager.generate_key("#{query}-#{options.sort.to_h}")

      @cache_manager.fetch(cache_key) do
        @geocoding_service.fetch_geocoding_data(query, options)
      end
    rescue StandardError => e
      handle_error(e, query)
      []
    end

    private

    # Validates the query to ensure it is not blank
    #
    # @param query [String] The address query to validate
    # @raise [ArgumentError] If the query is blank
    def validate_query(query)
      raise ArgumentError, 'Query cannot be blank' if query.strip.empty?
    end

    # Handles errors by logging and optionally notifying
    #
    # @param error [Exception] The exception to handle
    # @param query [String] The address query associated with the error
    def handle_error(error, query)
      Rails.logger.error("[AddressLookupManager] Error during lookup for query: '#{query}'")
      Rails.logger.error("Error: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n")) if error.backtrace
    end
  end
end
