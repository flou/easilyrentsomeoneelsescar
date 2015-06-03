require "json"
require "date"

data = File.expand_path(File.dirname(__FILE__)) + '/data.json'
data = JSON.parse(File.read(data))

class Rentals
  include Enumerable
  def initialize
    @rentals = []
  end

  def <<(val)
    @rentals << val
  end

  def each(&block)
    @rentals.each(&block)
  end

  def to_hash
    { rentals: @rentals.map(&:to_hash) }
  end

  def balance
    { rentals: @rentals.map(&:balance) }
  end
end

class Car
  attr_reader :id, :price_per_day, :price_per_km
  def initialize(attributes)
    @id            = attributes["id"]
    @price_per_day = attributes["price_per_day"]
    @price_per_km  = attributes["price_per_km"]
  end
end

class Rental
  COMMISSION_RATE = 0.30
  ACTORS = [
    { who: "driver",     type: "debit"  },
    { who: "owner",      type: "credit" },
    { who: "insurance",  type: "credit" },
    { who: "assistance", type: "credit" },
    { who: "drivy",      type: "credit" }
  ]

  def initialize(attributes)
    @id         = attributes["id"]
    @car_id     = attributes["car_id"]
    @start_date = Date.parse(attributes["start_date"])
    @end_date   = Date.parse(attributes["end_date"])
    @distance   = attributes["distance"]

    @deductible = attributes.fetch("deductible_reduction")
    @options = {}
    @options[:deductible_reduction] = deductible_reduction

    @actions    = []

    @car = CARS.select { |car| car.id == @car_id }.first
  end

  # Duration in number of days
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
    commission * 0.50
  end

  def assistance_fee
    duration * 100
  end

  def drivy_fee
    commission - insurance_fee - assistance_fee
  end

  def to_hash
    {
      id: @id,
      price: rental_price,
      options: @options,
      commission: commissions
    }
  end

  def balance
    { id: @id, actions: list_actions}
  end

  def list_actions
    ACTORS.map do |actor|
      case actor[:who]
      when "driver"
        actor.merge(amount: (rental_price + deductible_reduction).to_i)
      when "owner"
        actor.merge(amount: (rental_price - commission).to_i)
      when "insurance"
        actor.merge(amount: insurance_fee.to_i)
      when "assistance"
        actor.merge(amount: assistance_fee.to_i)
      when "drivy"
        actor.merge(amount: (drivy_fee + deductible_reduction).to_i)
      end
    end
  end

  def deductible_reduction
    @deductible ? 4 * duration * 100 : 0
  end
end

CARS = []
data["cars"].each do |car|
  CARS << Car.new(car)
end

rentals = Rentals.new
data["rentals"].each do |rental|
  rentals << Rental.new(rental)
end

# puts JSON.pretty_generate(rentals.to_hash)
puts JSON.pretty_generate(rentals.balance)
