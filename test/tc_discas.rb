require "test/unit"

require_relative "../lib/discas"

class TestDiscas < Test::Unit::TestCase
  def setup
    @discas = Discas::RentalHistory.new("/Users/keyes/Desktop/discas/rentalLog.do.html")
    @discas.read(3)
  end

  def test_rentals
    p @discas.rentals
  end

  def test_write
    @discas.write('rentals.csv')
  end
end