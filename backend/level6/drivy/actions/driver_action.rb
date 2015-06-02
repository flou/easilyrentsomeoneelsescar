require_relative "generic_action"

module Drivy
  class DriverAction < GenericAction
    def initialize(rental_price, deductible_reduction)
      @value = (rental_price + deductible_reduction).to_i
    end

    def actor
      "driver"
    end

    def type(value)
      value > 0 ? "debit" : "credit"
    end
  end
end
