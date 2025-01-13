# frozen_string_literal: true

# app/serializers/address_serializer.rb
class AddressSerializer
  def initialize(addresses)
    @addresses = addresses
  end

  # Serializes the addresses into a standardized JSON format
  #
  # @return [Array<Hash>] Serialized list of address suggestions
  def serialize
    @addresses.map do |address|
      {
        full_address: address[:full_address],
        lat: address[:lat],
        lon: address[:lon]
      }
    end
  end
end
