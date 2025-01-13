# frozen_string_literal: true

require 'test_helper'

module Geocoder
  class AddressLookupControllerTest < ActionDispatch::IntegrationTest
    setup do
      @valid_params = { query: 'Mountain View' }
      @invalid_params = { query: '' }

      @mock_results = [
        { full_address: 'Mountain View, CA, USA', lat: 37.3860517, lng: -122.0838511 },
        { full_address: 'Mountain Home, ID, USA', lat: 43.132576, lng: -115.691198 }
      ]

      @serialized_results = [
        { full_address: 'Mountain View, CA, USA', lat: 37.3860517, lng: -122.0838511 },
        { full_address: 'Mountain Home, ID, USA', lat: 43.132576, lng: -115.691198 }
      ]
    end

    test 'should return address suggestions with valid parameters' do
      # Stub the AddressLookupManager and AddressSerializer
      ::Geocoder::AddressLookupManager.any_instance.stubs(:lookup_address).returns(@mock_results)
      AddressSerializer.any_instance.stubs(:serialize).returns(@serialized_results)

      get '/geocoder/address_lookup', params: @valid_params

      assert_response :success
      json_response = JSON.parse(response.body, symbolize_names: true)
      assert json_response[:success]
      assert_equal @serialized_results, json_response[:data]
      assert_equal 'Autocomplete results fetched successfully', json_response[:message]
    end

    test 'should return validation errors with invalid parameters' do
      get '/geocoder/address_lookup', params: @invalid_params

      assert_response :bad_request
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], "Query can't be blank"
    end

    test 'should handle unexpected errors gracefully' do
      ::Geocoder::AddressLookupManager.any_instance.stubs(:lookup_address).raises(StandardError, 'Unexpected error')

      get '/geocoder/address_lookup', params: @valid_params

      assert_response :internal_server_error
      json_response = JSON.parse(response.body, symbolize_names: true)
      refute json_response[:success]
      assert_includes json_response[:errors], 'An unexpected error occurred. Please try again later.'
    end
  end
end
