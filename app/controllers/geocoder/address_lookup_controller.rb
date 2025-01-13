# frozen_string_literal: true

# app/controllers/geocoder/autocomplete_controller.rb
module Geocoder
  # Handles address autocomplete requests by validating input, retrieving suggestions via a manager,
  # and serializing the response for the client.
  class AddressLookupController < ApplicationController
    include ResponseHelper # Include the response helper

    # Handles autocomplete for partial addresses
    #
    # @return [JSON] A serialized list of address suggestions
    def index
      query = Address.new(permitted_params)

      if query.valid?
        render_autocomplete_results(query)
      else
        render_validation_errors(query)
      end
    rescue StandardError => e
      handle_error(e)
    end

    private

    # Renders autocomplete results on valid query
    #
    # @param query [Address] Validated query object
    def render_autocomplete_results(query)
      results = fetch_address_suggestions(query.query)
      serialized_results = serialize_results(results)

      render_success(data: serialized_results, message: 'Autocomplete results fetched successfully')
    end

    # Renders validation errors
    #
    # @param query [Address] Query object with validation errors
    def render_validation_errors(query)
      render_error(errors: query.errors.full_messages, status: :bad_request)
    end

    # Fetches address suggestions using the AddressLookupManager
    #
    # @param query [String] The validated query string
    # @return [Array<Hash>] List of address suggestions
    def fetch_address_suggestions(query)
      AddressLookupManager.new.lookup_address(query)
    end

    # Serializes address suggestions for the response
    #
    # @param results [Array<Hash>] Raw address suggestions
    # @return [Array<Hash>] Serialized suggestions
    def serialize_results(results)
      ::AddressSerializer.new(results).serialize
    end

    # Permits and sanitizes request parameters
    #
    # @return [ActionController::Parameters] Permitted parameters
    def permitted_params
      params.permit(:query)
    end

    # Handles unexpected errors and renders a standardized error response
    #
    # @param error [Exception] The error to handle
    def handle_error(error)
      Rails.logger.error("[AutocompleteController] Error: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n")) if error.backtrace

      render_error(errors: 'An unexpected error occurred. Please try again later.', status: :internal_server_error)
    end
  end
end
