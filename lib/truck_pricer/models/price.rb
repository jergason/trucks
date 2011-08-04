require 'dm-serializer'

# WARNING: Due to legacy database concerns, the field names on the model
# don't match up too well with what they actually represent.
#
# If the mileage on the truck is below the mileage_cutoff,
# price_per_mile is the amount per mile below the mileage_cutoff that will be
# _added_ to the base price of the truck. If the mileage on the truck is above
# the mileage_cutoff, price_per_mile_after_cutoff is the amount that will be
# deducted from the base price of the truck.

module TruckPricer
  class Price
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :price, Decimal
    property :mileage_cutoff, Integer, :required => true
    #price to add per mile if it is below the cutoff mileage
    property :price_per_mile, Decimal, :required => true, :scale => 2, :precision => 10
    property :price_per_mile_after_cutoff, Decimal, :required => true, :scale => 2, :precision => 10
    #TODO : give these sensible defaults?
    property :second_mileage_cutoff, Integer, :required => true
    property :price_per_mile_after_second_cutoff, Decimal, :required => true, :scale => 2, :precision => 10
    property :extra_deduct, Decimal, :required => false, :scale => 2, :precision => 10, :default => 0.0
    property :created_at, DateTime
    property :created_on, Date
    property :updated_at, DateTime
    property :updated_on, Date

    belongs_to :truck_model, :required => false
    belongs_to :engine, :required => false
    belongs_to :year, :required => false

    #Calculate price for a truck with the given milage
    def price_for_miles_and_base_price(miles)
      #if miles between first and second cutoffs
      if (miles > self.mileage_cutoff and miles < self.second_mileage_cutoff)
        calculated_price = self.price - ((miles - self.mileage_cutoff) * self.price_per_mile_after_cutoff)
      elsif miles > self.second_mileage_cutoff #if mileage greater than second cutoff
        calculated_price = self.price - ((miles - self.second_mileage_cutoff) * self.price_per_mile_after_second_cutoff) -
          ((self.second_mileage_cutoff - self.mileage_cutoff) * self.price_per_mile_after_cutoff)
      else #mileage less than first cutoff, so a truck with less milage has a higher price
        calculated_price = self.price + ((self.mileage_cutoff - miles) * self.price_per_mile)
      end
      #deduct from everything
      calculated_price = calculated_price - self.extra_deduct
      return calculated_price > 0.0 ? calculated_price : 0.0
    end
  end
end
