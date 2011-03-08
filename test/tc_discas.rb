require "test/unit"

require_relative "../lib/discas"

class TestDiscas < Test::Unit::TestCase
  def setup
    @discas = Discas::RentalHistory.new("/Users/keyes/Desktop/discas/rentalLog.do.html")
  end

  def test_read
    @discas.read
    assert_equal(20, @discas.rentals.size)
    @discas.read(3)
    assert_equal(60, @discas.rentals.size)
    @discas.read(2..5)
    assert_equal(80, @discas.rentals.size)
  end

  def test_write
    @discas.read(3).write('rentals.csv')
  end

  def test_title_sortable
    title = @discas.read.rentals.first[4]
    assert_match(/\D0\d\D?$/, title)
    title = @discas.read(1, false).rentals.first[4]
    assert_match(/\D\d\D?$/, title)
  end

  def test_read_arguments
    assert(@discas.read, "Failure message.")
    assert(@discas.read(2), "Failure message.")
    assert(@discas.read(1..3), "Failure message.")
    # assert_raise(ArgumentError) { @discas.read("one") }
  end
end