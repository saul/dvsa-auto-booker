require 'dotenv'
Dotenv.load

require_relative 'booking_driver'

driver = BookingDriver.new

options = {
  username: ENV.fetch('DVSA_DRIVING_LICENSE_NUMBER'),
  password: ENV.fetch('DVSA_APPLICATION_REF_NUMBER'),
  centre_desired: ENV.fetch('TEST_CENTRE_DESIRED'),
  earliest_date: DateTime.parse(ENV.fetch('TEST_EARLIEST_DATE')),
  latest_date: DateTime.parse(ENV.fetch('TEST_LATEST_DATE'))
}

puts '[*] Running'
driver.run options
