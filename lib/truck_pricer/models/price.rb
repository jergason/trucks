require 'dm-serializer'

module TruckPricer
  class Price
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :price, Float
    property :mileage_cutoff, Integer, :required => true
    property :price_per_mile, Decimal, :required => true, :scale => 2, :precision => 10
    property :price_per_mile_after_cutoff, Decimal, :required => true, :scale => 2, :precision => 10
    property :created_at, DateTime
    property :created_on, Date
    property :updated_at, DateTime
    property :updated_on, Date

    belongs_to :truck_model, :required => false
    belongs_to :engine, :required => false
    belongs_to :year, :required => false

    #Calculate price for a truck with the given milage
    def price_for_miles_and_base_price(miles)
      if (miles > self.mileage_cutoff)
        mileage_price = (self.mileage_cutoff * self.price_per_mile) + ((miles - self.mileage_cutoff) * self.price_per_mile_after_cutoff)
      else
        mileage_price = miles * self.price_per_mile
      end
      return self.price - mileage_price
    end
  end
end
