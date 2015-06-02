module Drivy
  class RentalModification

    attr_accessor :id, :rental_id, :distance, :end_date, :start_date

    def initialize(attributes)
      @id         = attributes.fetch("id")
      @rental_id  = attributes.fetch("rental_id")
      fail "rental_id is required" unless @rental_id

      date = attributes.fetch("end_date", nil)
      @end_date   = Date.parse(date) if date

      date = attributes.fetch("start_date", nil)
      @start_date = Date.parse(date) if date

      @distance   = attributes.fetch("distance", nil)
    end

    def output(actions)
      {
        id: @id,
        rental_id: @rental_id,
        actions: actions
      }
    end
  end
end
