module TruckPricer
  class Formula
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :mileage_threshold, Integer
    property :price_per_mile, Decimal
    property :price_per_mile_after_threshold, Decimal
    property :created_at, DateTime
    property :created_on, Date
    property :updated_at, DateTime
    property :updated_on, Date
  end

  #calculate a base price. Assume that
  #the price and miles are well-formed, validated
  #properly already.
  def price_for_miles_and_base_price(miles, base_price)
    if (miles > mileage_threshold)
      mileage_price = (mileage_threshold * price_per_mile) + ((miles - mileage_threshold) * price_per_mile_after_threshold)
    else
      mileage_price = miles * price_per_mile
    end
    return mileage_price + base_price
  end
end
