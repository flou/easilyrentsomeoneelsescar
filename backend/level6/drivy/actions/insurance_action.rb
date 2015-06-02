require_relative "generic_action"

module Drivy
  class InsuranceAction < GenericAction
    def initialize(insurance_fee)
      @value = insurance_fee.to_i
    end

    def actor
      "insurance"
    end
  end
end
