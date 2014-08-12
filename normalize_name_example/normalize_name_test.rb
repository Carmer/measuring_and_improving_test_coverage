require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require_relative 'normalize_name'

class NormalizeNameTest < Minitest::Test
  def test_it_returns_the_name_when_it_exists
    assert_equal 'Josh', normalize_name('Josh', :masculine)
  end

  def test_it_returns_the_gendered_default_when_there_is_no_name
    assert_equal 'Jane Doe', normalize_name(nil, :feminine)
  end
end
