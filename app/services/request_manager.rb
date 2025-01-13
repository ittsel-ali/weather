# app/services/request_manager.rb
require 'rest-client'
require 'json'

class RequestManager
  MAX_RETRIES = 3 # Maximum number of retries for transient errors

  # Performs an HTTP GET request with retry logic
  #
  # @param url [String] The URL to send the request to
  # @param params [Hash] Query parameters for the request
  # @param headers [Hash] Headers for the request
  # @return [Hash, nil] The parsed response as a hash or nil if the request fails
  def self.get(url, params: {}, headers: {})
    with_retries do
      response = RestClient.get(url, params: params, headers: headers)
      parse_response(response)
    end
  end

  private

  # Executes the given block with retry logic for transient errors
  #
  # @yield The block containing the code to execute with retries
  # @return [Object] The result of the block if successful
  # @raise [Exception] The last exception if all retries fail
  def self.with_retries
    retries = 0

    begin
      yield # Execute the block
    rescue RestClient::ExceptionWithResponse => e
      retries += 1
      if retries <= MAX_RETRIES && retryable_error?(e.response)
        Rails.logger.warn("Retrying request... Attempt #{retries} of #{MAX_RETRIES}")
        sleep(retry_backoff(retries)) # Exponential backoff
        retry
      end
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end
  end

  # Parses the HTTP response
  #
  # @param response [RestClient::Response] The HTTP response object
  # @return [Hash] The parsed response body
  def self.parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Response Parsing Error: #{e.message}"
  end

  # Determines if an error is retryable
  #
  # @param response [RestClient::Response] The HTTP response object
  # @return [Boolean] True if the error is retryable, false otherwise
  def self.retryable_error?(response)
    [429, 500, 502, 503, 504].include?(response.code) # Common transient error codes
  end

  # Calculates the backoff time for retries (exponential backoff)
  #
  # @param retries [Integer] The current retry attempt
  # @return [Float] The backoff time in seconds
  def self.retry_backoff(retries)
    (2**retries) + rand(0..1) # Exponential backoff with jitter
  end

  # Handles HTTP and other errors
  #
  # @param error [Exception] The exception to handle
  # @return [nil] Returns nil after logging the error
  def self.handle_error(error)
    Rails.logger.error("Request Error: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n")) if error.respond_to?(:backtrace)
    nil
  end
end
