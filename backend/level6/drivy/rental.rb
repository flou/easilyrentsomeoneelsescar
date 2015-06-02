require_relative "actions/driver_action"
require_relative "actions/owner_action"
require_relative "actions/assistance_action"
require_relative "actions/insurance_action"
require_relative "actions/drivy_action"

module Drivy
  class Rental

    attr_accessor :id, :distance, :end_date, :start_date

    COMMISSION_RATE = 0.30
    INSURANCE_FEE   = 0.50
    ASSISTANCE_FEE  = 100

    def initialize(attributes)
      @id         = attributes.fetch("id")
      @car_id     = attributes.fetch("car_id", nil)
      date = attributes.fetch("start_date", nil)
      @start_date = Date.parse(date) if date
      date = attributes.fetch("end_date", nil)
      @end_date   = Date.parse(date) if date
      @distance   = attributes.fetch("distance", nil)
      @car        = CARS[@car_id]

      @deductible = attributes.fetch("deductible_reduction", nil)
      @options    = {}
      @options[:deductible_reduction] = deductible_reduction
      @actions    = calculate_actions
    end

    def duration
      1 + (@end_date - @start_date).to_i
    end

    def price_for_duration
      duration.times.map do |n|
        factor = case n
          when 0 then 1
          when 1...4  then 0.9
          when 4...10 then 0.7
          else 0.5
        end
        factor * @car.price_per_day
      end.reduce(:+).to_i
    end

    def price_for_distance
      @distance * @car.price_per_km
    end

    def rental_price
      price_for_duration + price_for_distance
    end

    def commissions
      {
        insurance_fee:  insurance_fee.to_i,
        assistance_fee: assistance_fee.to_i,
        drivy_fee:      drivy_fee.to_i
      }
    end

    def commission
      rental_price * COMMISSION_RATE
    end

    def insurance_fee
      commission * INSURANCE_FEE
    end

    def assistance_fee
      duration * ASSISTANCE_FEE
    end

    def drivy_fee
      commission - insurance_fee - assistance_fee
    end

    def summary
      {
        id: @id,
        price: rental_price,
        options: @options,
        commission: commissions
      }
    end

    def balance
      { id: @id, actions: @actions }
    end

    def calculate_actions
      actions = []
      actions << DriverAction.new(rental_price, deductible_reduction).output
      actions << OwnerAction.new(rental_price, commission).output
      actions << InsuranceAction.new(insurance_fee).output
      actions << AssistanceAction.new(assistance_fee).output
      actions << DrivyAction.new(drivy_fee, deductible_reduction).output
      actions
    end

    def deductible_reduction
      @deductible ? 4 * duration * 100 : 0
    end

    def updated_actions(mod)
      new_rental = self.dup
      new_rental.distance   = mod.distance   if mod.distance
      new_rental.end_date   = mod.end_date   if mod.end_date
      new_rental.start_date = mod.start_date if mod.start_date
      new_rental.calculate_actions.zip(self.calculate_actions).map do |row|
        act = row[0]
        value = act[:value] - row[1][:value]
        value *= -1 if act[:who] == "driver"
        {
          who:    act[:who],
          type:   value < 0 ? "debit" : "credit",
          amount: value.abs
        }
      end
    end
  end
end
