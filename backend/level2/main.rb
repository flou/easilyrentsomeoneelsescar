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
  def initialize(attributes)
    @id         = attributes["id"]
    @car_id     = attributes["car_id"]
    @start_date = Date.parse(attributes["start_date"])
    @end_date   = Date.parse(attributes["end_date"])
    @distance   = attributes["distance"]

    @car = CARS.select { |car| car.id == @car_id }.first
  end

  # Duration in number of days
  def duration
    1 + (@end_date - @start_date).to_i
  end

  def price_for_duration
    new_price = @car.price_per_day
    cost = 0
    duration.times do |n|
      case n
      when 1
        new_price = @car.price_per_day * 0.9
      when 4
        new_price = @car.price_per_day * 0.7
      when 10
        new_price = @car.price_per_day * 0.5
      end
      cost += new_price
    end
    cost.to_i
  end

  def price_for_distance
    @distance * @car.price_per_km
  end

  def price_of_rental
    price_for_duration + price_for_distance
  end

  def to_hash
    { id: @id, price: price_of_rental }
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

puts JSON.pretty_generate(rentals.to_hash)
