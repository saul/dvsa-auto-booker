require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist

class Slot
  attr_reader :id, :time, :date

  def initialize(id:, time:, date:)
    @id = id
    @time = time
    @date = date
  end
end

class BookingDriver
  include Capybara::DSL

  def run(username:, password:, centre_desired:, earliest_date:, latest_date:)
    puts '1. Logging in'
    login(username, password)

    puts '2. Retrieving current booking details'
    current_time, current_centre = get_current_details
    current_date = current_time.to_date

    puts '3. Checking available dates'
    slots = get_slots centre_desired
    desirable_slots = slots.select { |slot| slot.date >= earliest_date and slot.date <= latest_date }

    if !desirable_slots.any?
      puts '[!] No desirable slots'
      return false
    end

    if current_centre == centre_desired
      if !desirable_slots.any? { |slot| slot.date > current_date }
        puts '[!] Available slots are no more desirable than the currently booked slot'
        return false
      end
    end if

    # just grab the latest slot that we desire
    # the slots are already sorted in ascending time order, so the last one will be the one closest to the end of our
    # desired booking period
    desired_slot = desirable_slots.last
    puts "4. Booking slot #{desired_slot.id} at #{desired_slot.time}"
    book_slot desired_slot.id

    true
  end

  private

  def login(username, password)
    visit 'https://driverpracticaltest.direct.gov.uk/login'
    fail 'CAPTCHA on login form' if page.has_css? '#recaptcha_widget_div'

    fill_in 'username', with: username
    fill_in 'password', with: password
    click_button 'Continue'

    fail "Unexpected host after login `#{page.current_host}`" unless page.current_host == 'https://driverpracticaltest.direct.gov.uk'
    fail "Unexpected page after login `#{page.current_path}`" unless page.current_path == '/manage'
  end

  def get_section_text(elem)
    elem.first('.contents dd').text
  end

  def get_current_details
    date_time_section = find('h1', text: 'Date and time of test').find(:xpath, '../..')
    date_time_text = get_section_text date_time_section
    date_time = DateTime.parse date_time_text
    puts "Date/time: #{get_section_text date_time_section} (#{date_time})"

    test_centre_section = find('h1', text: 'Test centre').find(:xpath, '../..')
    test_centre = get_section_text test_centre_section
    puts "Test centre: #{test_centre}"

    return date_time, test_centre
  end

  def get_slots(centre)
    # move through the 'Change test centre' form
    click_on 'test-centre-change'
    fill_in 'testCentreName', with: centre
    click_button 'Find test centres'

    # click on the test centre
    # if there's more than one result, an exception is thrown
    find('.test-centre-details-link').click

    # map all the available slots to Slot instances
    all('#availability-results .button-board a', minimum: 1).map do |slot|
      time = DateTime.parse(slot.text)
      Slot.new(id: slot['id'], time: time, date: time.to_date)
    end
  end

  def book_slot(slot_locator)
    click_on slot_locator

    click_on 'slot-warning-continue'

    click_on 'i-am-candidate' if page.has_css? '#candidate-or-not'

    click_on 'confirm-changes'
  end
end
