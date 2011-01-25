module TruckPricer
  class Year
    include DataMapper::Resource
    VIN_INDEX = 9
    property :id, Serial, :key => true
    property :name, String, :required => true
    property :vin_string, String
    property :created_on, DateTime, :default => lambda { |r, p| Time.now }
    property :updated_on, DateTime, :default => lambda { |r, p| Time.now }

    has n, :prices

    before :save do
      update_on = Time.now
    end
  end
end
