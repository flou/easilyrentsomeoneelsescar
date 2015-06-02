require "json"
require "date"

require_relative "drivy/car"
require_relative "drivy/rental"
require_relative "drivy/rentals"
require_relative "drivy/rental_modification"

data = File.expand_path(File.dirname(__FILE__)) + "/data.json"
data = JSON.parse(File.read(data))

CARS = {}
data["cars"].each do |car|
  CARS[car["id"]] = Drivy::Car.new(car)
end

rentals = Drivy::Rentals.new
data["rentals"].each do |rental|
  rentals.register_rental(rental)
end

data["rental_modifications"].each do |mod|
  rentals.register_modification(mod)
end

puts JSON.pretty_generate rentals.balance
puts JSON.pretty_generate rentals.compute_modifications
