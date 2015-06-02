module Drivy
  class GenericAction
    def type(value)
      value < 0 ? "debit" : "credit"
    end

    def actor; end

    def output
      action         = { who: actor }
      action[:type]  = type(@value)
      action[:value] = @value.abs
      action
    end
  end
end
