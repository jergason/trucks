module TruckPricer
  class Formula
    include DataMapper::Resource

    property :id, Serial, :key => true, :required => true
    property :mileage_cutoff, Integer, :required => true
    property :price_per_mile, Decimal, :required => true, :scale => 2, :precision => 10
    property :price_per_mile_after_cutoff, Decimal, :required => true, :scale => 2, :precision => 10
    property :created_at, DateTime
    property :created_on, Date
    property :updated_at, DateTime
    property :updated_on, Date
  end

  #calculate a base price. Assume that
  #the price and miles are well-formed, validated
  #properly already.
  def price_for_miles_and_base_price(miles, base_price)
    if (miles > self.mileage_cutoff)
      mileage_price = (self.mileage_cutoff * self.price_per_mile) + ((miles - self.mileage_cutoff) * self.price_per_mile_after_cutoff)
    else
      mileage_price = miles * self.price_per_mile
    end
    return mileage_price + base_price
  end
end
