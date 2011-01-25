module TruckPricer
  class Model
    include DataMapper::Resource

    property :id, Serial
    property :name, String
    property :vin_string, String
    property :created_on, DateTime, :default => lambda { |r, p| Time.now }
    property :updated_on, DateTime, :default => lambda { |r, p| Time.now }
    
    before :save do
      update_on = Time.now
    end
  end
end


