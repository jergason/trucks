module TruckPricer
  class Price
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :price, Float

    has 1, :truck_model
    has 1, :engine
    has 1, :year
  end
end
