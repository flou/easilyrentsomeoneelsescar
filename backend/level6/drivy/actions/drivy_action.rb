require_relative "generic_action"

module Drivy
  class DrivyAction < GenericAction
    def initialize(drivy_fee, deductible_reduction)
      @value = (drivy_fee + deductible_reduction).to_i
    end

    def actor
      "drivy"
    end
  end
end

