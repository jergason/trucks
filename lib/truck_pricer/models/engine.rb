module TruckPricer
  class Engine
    include DataMapper::Resource
    VIN_INDEX = 4
    property :id, Serial, :key => true
    property :name, String, :required => true
    property :vin_string, String
    property :created_at, DateTime
    property :created_on, Date
    property :updated_at, DateTime
    property :updated_on, Date

    has n, :prices
  end
end
