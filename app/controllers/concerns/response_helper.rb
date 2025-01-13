# app/controllers/concerns/response_helper.rb
module ResponseHelper
  extend ActiveSupport::Concern

  # Renders a successful JSON response
  #
  # @param data [Object] The data to include in the response
  # @param message [String] A success message
  # @param status [Symbol] The HTTP status (default: :ok)
  def render_success(data: {}, message: 'Success', status: :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  # Renders an error JSON response
  #
  # @param errors [Array<String>, String] The errors to include in the response
  # @param status [Symbol] The HTTP status (default: :unprocessable_entity)
  def render_error(errors: [], status: :unprocessable_entity)
    render json: {
      success: false,
      message: 'Error occurred',
      errors: Array(errors)
    }, status: status
  end
end
