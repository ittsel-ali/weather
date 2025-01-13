# app/models/weather/forecast_query.rb
module Weather
  class Forecast
    include ActiveModel::Model

    # Attributes
    attr_accessor :lat, :lon

    # Validations
    validates :lat, presence: true,
                    numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
    validates :lon, presence: true,
                    numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

    # Initialize with attributes
    def initialize(attributes = {})
      super
    end
  end
end
