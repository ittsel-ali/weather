# app/models/geocoder/address_autocomplete_query.rb
module Geocoder
  class Address
    include ActiveModel::Model

    # Attributes
    attr_accessor :query

    # Validations
    validates :query, presence: true

    # Initialize with optional parameters
    def initialize(attributes = {})
      super
    end
  end
end
