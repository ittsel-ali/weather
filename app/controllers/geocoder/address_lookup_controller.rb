# app/controllers/geocoder/autocomplete_controller.rb
module Geocoder
  class AddressLookupController < ApplicationController
    include ResponseHelper # Include the response helper

    # Handles autocomplete for partial addresses
    #
    # @return [JSON] A serialized list of address suggestions
    def index
      query = Address.new(permitted_params)

      if query.valid?
        address_lookup_manager = AddressLookupManager.new

        # Perform the address lookup
        results = address_lookup_manager.lookup_address(query.query)

        # Serialize the results using the custom serializer
        serialized_results = ::AddressSerializer.new(results).serialize

        # Render the results in a standardized success response
        render_success(data: serialized_results, message: 'Autocomplete results fetched successfully')
      else
        # Render validation errors in a standardized error response
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
