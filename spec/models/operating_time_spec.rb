require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OperatingTime do
  before(:each) do
    @place = mock_model(Place)
    @valid_attributes = {
      :place_id  => @place.id,
      :startDate => Date.yesterday,
      :endDate   => Date.tomorrow
    }
  end

  it "should create a new instance given valid attributes" do
    OperatingTime.create!(@valid_attributes)
  end

  # TODO: Add spec code
  it "should not create a new instance without a valid start time"
  it "should not create a new instance without a valid length"
  it "should not create a new instance without a valid Place reference"
  it "should not create a new instance without a valid start date"
  it "should not create a new instance without a valid end date"
end
