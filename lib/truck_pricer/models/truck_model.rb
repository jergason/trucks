module TruckPricer
  class TruckModel
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

    def to_s
      return "<TruckPricer::TruckModel id: #{self.id} name: #{self.name}>"
    end
  end
end


