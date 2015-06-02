require_relative "generic_action"

module Drivy
  class AssistanceAction < GenericAction
    def initialize(assistance_fee)
      @value = assistance_fee.to_i
    end

    def actor
      "assistance"
    end
  end
end
