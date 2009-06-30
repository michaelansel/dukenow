require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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

def build_place_from_times(times = [])
  place = Place.create!(@valid_attributes)
  regularTimes = []
  specialTimes = []

  times.each do |time|
    ot = mock_model(OperatingTime)
    ot.stub(:opensAt).and_return(time[:start])
    ot.stub(:length).and_return(time[:length])
    ot.stub(:override).and_return(time[:override] || 0)
    ot.stub(:startDate).and_return(time[:startDate] || Date.yesterday)
    ot.stub(:endDate).and_return(time[:endDate] || Date.tomorrow)
    ot.stub(:flags).and_return(time[:flags] || OperatingTime::ALL_DAYS)
    ot.stub(:place_id).and_return(place.id)
    ot.stub(:to_times).with(instance_of(Time)).and_return do |at|
      open = at.midnight + ot.opensAt
      close = open + ot.length
      [open,close]
    end

    if time.keys.include?(:override) and time[:override] == 1
      specialTimes << ot
    elsif time[:override].nil? or time[:override] == 0
      regularTimes << ot
    end
  end

  place.stub(:operating_times).and_return(regularTimes + specialTimes)
  place.stub(:regular_operating_times).and_return(regularTimes)
  place.stub(:special_operating_times).and_return(specialTimes)

  place
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

  it "should build a valid dailySchedule" do
    #TODO Test against a valid schedule as well
    place = Place.create!(@valid_attributes)
    place.should_receive(:schedule).with(instance_of(Time), instance_of(Time)).and_return([])
    place.daySchedule(Date.today).should == []
  end

  describe "that is currently open" do
    it_should_behave_like "a Place with OperatingTimes"

    before(:each) do
      @place = build_place_from_times([{:start =>  6.hours, :length => 2.hours}])
      @at = Time.now.midnight + 7.hours
    end

    it "should be open" do
      @place.open?(@at).should == true
    end
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
