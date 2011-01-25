module TruckPricer
  class Model
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :name, String, :required => true
    property :vin_string, String
    property :created_on, DateTime, :default => lambda { |r, p| Time.now }
    property :updated_on, DateTime, :default => lambda { |r, p| Time.now }

    belongs_to :price_formula, :required => false
    
    before :save do
      update_on = Time.now
    end
  end
end


