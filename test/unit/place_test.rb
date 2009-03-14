require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  fixtures :operating_times

  test "regular_operating_times returns empty array if none" do
    assert_not_nil Place.new.regular_operating_times
  end

  test "special_operating_times returns empty array if none" do
    assert_not_nil Place.new.special_operating_times
  end

  test "regular_operating_times are all not special" do
    place = places(:greathall)
    assert_not_equal [],place.regular_operating_times, "This test is worthless without regular_operating_times"

    place.regular_operating_times.each do |optime|
      assert !(optime.special)
    end
  end

  test "special_operating_times are all special" do
    place = places(:greathall)
    assert_not_equal [],place.special_operating_times, "This test is worthless without special_operating_times"

    place.special_operating_times.each do |optime|
      assert optime.special
    end
  end
end
