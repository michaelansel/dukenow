require 'test_helper'

class EateryTest < ActiveSupport::TestCase
  fixtures :eateries
  fixtures :regular_operating_times
  fixtures :special_operating_times

  test "should create Eatery" do
    assert Eatery, Eatery.new
  end

  test "Eatery should be open during the regular operating time" do
    regular_operating_time(:open).eatery = eatery(:loop)
    assert true, eatery(:loop).open
  end
end
