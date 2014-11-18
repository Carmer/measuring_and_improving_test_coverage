require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require_relative 'speeding_ticket'

class SpeedingTicketTest < Minitest::Test
  def test_it_is_100_when_more_than_doubling_the_speed_limit
    assert_equal 100, speeding_ticket(44, 20)
  end

  def test_it_is_250_when_tripling_speed_limit
    assert_equal 250, speeding_ticket(65, 20)
  end
end
