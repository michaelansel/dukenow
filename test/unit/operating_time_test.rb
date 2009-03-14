require 'test_helper'

class OperatingTimeTest < ActiveSupport::TestCase
  test "special method matches special flag" do
    optime = OperatingTime.new

    optime.flags = OperatingTime::ALL_FLAGS
    assert_equal true, optime.special

    optime.flags = OperatingTime::ALL_FLAGS & ~OperatingTime::SPECIAL_FLAG
    assert_equal false, optime.special
  end
  
  test "special= returns the newly set value of special" do
    optime = OperatingTime.new

    assert_equal true, (optime.special = true)
    assert_equal false, (optime.special = false)
  end

  test "special= only changes special flag" do
    optime = OperatingTime.new
    optime.flags = OperatingTime::ALL_FLAGS

    optime.special = true
    assert_equal OperatingTime::ALL_FLAGS, optime.flags

    optime.special = false
    proper_flags = OperatingTime::ALL_FLAGS & ~OperatingTime::SPECIAL_FLAG
    assert_equal proper_flags, optime.flags
  end
end
