require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OperatingTime do
  before(:each) do
    @place = mock_model(Place)
    @valid_attributes = {
      :place_id => @place.id
    }
  end

  it "should create a new instance given valid attributes" do
    OperatingTime.create!(@valid_attributes)
  end
end
