module Drivy
  class Rentals
    attr_accessor :rentals, :modifications

    def initialize
      @rentals       = {}
      @modifications = {}
    end

    def register_rental(rental)
      @rentals[rental["id"]] = Drivy::Rental.new(rental)
    end

    def register_modification(mod)
      @modifications[mod["id"]] = Drivy::RentalModification.new(mod)
    end

    def summary
      { rentals: @rentals.values.map(&:summary) }
    end

    def balance
      { rentals: @rentals.values.map(&:balance) }
    end

    def compute_modifications
      rental_modifications = @modifications.values.map do |mod|
        rental = @rentals[mod.rental_id]
        {
          id:        mod.id,
          rental_id: rental.id,
          actions:   rental.updated_actions(mod)
        }
      end
      { rental_modifications: rental_modifications }
    end
  end
end
