require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/schedules')

describe Place do
  before(:each) do
    @valid_attributes = {
      :name => 'Test Place',
      :location => 'Somewhere',
      :phone => '(919) 555-1212'
    }

    @place = Place.create!(@valid_attributes)
  end

  it "should create a new, valid instance given valid attributes" do
    Place.create!(@valid_attributes).should be_valid
  end

  it "should not create a new instance without a name" do
    @valid_attributes.delete(:name)
    lambda { Place.create!(@valid_attributes) }.should raise_error
  end

  it "should produce valid XML"

  it "should produce valid JSON"

  ##############################
  ###                        ###
  ###       Scheduling       ###
  ###                        ###
  ##############################

  it_should_behave_like "a Place with scheduling capabilities"
  it_should_behave_like "a Place with valid times"

  describe "a Place with no times" do
    before(:each) do
      # Don't allow any times
      @place.add_constraint { false }
      @at = Time.now.midnight + 7.hours
    end

    it_can "be closed now", "be closed all day", "be closed for the day"
  end
end







=begin
# TODO Create mocks for OperatingTime so we can test the scheduling methods
describe "a Place with OperatingTimes", :shared => true do
  describe "that are valid now" do
    it "should have a valid schedule" do
    end
    it "should have a valid daily schedule"
    it "should have a valid current schedule"
    it "should have regular OperatingTimes"
    it "should have special OperatingTimes"
  end

  describe "that are not valid now" do
  end
end


describe Place do
  before(:each) do
    @valid_attributes = {
      :name => 'Test Place',
      :location => 'Somewhere',
      :phone => '(919) 555-1212'
    }
  end

  it "should build a valid dailySchedule" do
    #TODO Test against a valid schedule as well
    place = Place.create!(@valid_attributes)
    place.should_receive(:schedule).with(instance_of(Time), instance_of(Time)).and_return([])
    place.daySchedule(Date.today).should == []
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
=end
