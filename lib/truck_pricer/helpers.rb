module TruckPricer
  module Helpers
    def options_array(model_list)
      arr = []
      model_list.each do |m|
        arr << [m.name, m.id.to_s]
      end
      arr
    end
  end
end
