require_relative "generic_action"

module Drivy
  class OwnerAction < GenericAction
    def initialize(rental_price, commission)
      @value = (rental_price - commission).to_i
    end

    def actor
      "owner"
    end
  end
end
