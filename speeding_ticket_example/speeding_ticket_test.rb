require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require_relative 'speeding_ticket'

class SpeedingTicketTest < Minitest::Test
  def test_it_is_50_when_exceeding_speed_limit
    assert_equal 50, speeding_ticket(25, 20) # going 5 mph over
  end

  def test_it_is_100_when_more_than_doubling_the_speed_limit
    assert_equal 100, speeding_ticket(41, 20)
  end
end
