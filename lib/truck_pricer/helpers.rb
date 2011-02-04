module TruckPricer
  module Helpers
    def options_array(model_list)
      arr = []
      model_list.each do |m|
        arr << [m.name, m.id.to_s]
      end
      arr
    end

    #assume decimal is a properly formatted string
    def format_as_currency(decimal)
      decimal_copy = decimal.clone
      regex = /(-?[0-9]+)([0-9]{3})/
      while decimal_copy =~ regex
        decimal_copy.gsub!(regex, "\\1,\\2")
      end
      "$#{decimal_copy}"
    end
  end
end
