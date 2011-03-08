#-*-encoding: utf-8-*-

module Discas
  require_relative 'discas/rental_history'
end

if __FILE__ == $0
  discas = Discas::RentalHistory.new("/path/to/rentalLog.do.html", )
  if discas.read(1..3)
    puts "Successfully read"
  end
  if discas.write('rentals.csv')
    puts "Successfully write"
  end
end
