require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# TODO Create mocks for OperatingTime so we can test the scheduling methods
describe "a Place with OperatingTimes", :shared => true do
  it "should have a valid daily schedule"
  it "should have a valid current schedule"
  it "should have regular OperatingTimes"
  it "should have special OperatingTimes"
end

describe Place do
  before(:each) do
    @valid_attributes = {
      :name => 'Test Place',
      :location => 'Somewhere',
      :phone => '(919) 555-1212'
    }
  end

  it "should create a new instance given valid attributes" do
    Place.create!(@valid_attributes)
  end

  it "should not create a new instance without a name" do
    @valid_attributes.delete(:name)
    lambda { Place.create!(@valid_attributes) }.should raise_error
  end

  describe "that is currently open" do
    it_should_behave_like "a Place with OperatingTimes"

    it "should be open"
  end

  describe "that is closed, but opens later today" do
    it_should_behave_like "a Place with OperatingTimes"

    it "should be closed"
    it "should have a schedule for later today"
  end

  describe "that is closed for the day" do
    it_should_behave_like "a Place with OperatingTimes"

    it "should be closed"
  end
  describe "that is not open at all today" do
    it_should_behave_like "a Place with OperatingTimes"

    it "should be closed"
    it "should not have a schedule for the remainder of today"
  end

  describe "that is open past midnight today" do
    it_should_behave_like "a Place with OperatingTimes"
  end
  describe "that was open past midnight yesterday" do
    it_should_behave_like "a Place with OperatingTimes"
  end

###### Special Schedules ######
  describe "that is normally open, but closed all day today" do
    it_should_behave_like "a Place with OperatingTimes"
  end
  describe "that has special (extended) hours" do
    it_should_behave_like "a Place with OperatingTimes"
  end
  describe "that has special (shortened) hours" do
    it_should_behave_like "a Place with OperatingTimes"
  end
end
