# frozen_string_literal: true

# app/services/request_manager.rb
# Handles HTTP GET requests with retry logic, error handling, exponential backoff, and JSON response parsing.
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

  # Executes the given block with retry logic for transient errors
  def self.with_retries
    retries = 0
    begin
      yield
    rescue RestClient::ExceptionWithResponse => e
      handle_retry(e, retries += 1) ? retry : handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end
  end

  # Handles the retry logic, including backoff and retry determination
  #
  # @param error [RestClient::ExceptionWithResponse] The exception raised
  # @param retries [Integer] The current retry count
  # @return [Boolean] True if the request should be retried, false otherwise
  def self.handle_retry(error, retries)
    if retries <= MAX_RETRIES && retryable_error?(error.response)
      sleep(retry_backoff(retries))
      true
    else
      false
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
