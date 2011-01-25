require 'dm-serializer'

module TruckPricer
  class Price
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :price, Float

    belongs_to :truck_model, :required => false
    belongs_to :engine, :required => false
    belongs_to :year, :required => false
  end
end
