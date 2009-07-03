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

    @place.class_eval <<EOM
      attr_accessor :constraints

      def operating_times
        regular_operating_times + special_operating_times
      end

      def regular_operating_times
        @regular_operating_times ||= []
      end
      def special_operating_times
        @special_operating_times ||= []
      end
EOM
    @place.regular_operating_times.should == []
    @place.special_operating_times.should == []
  end

  it_should_behave_like "a Place with scheduling capabilities"
  it_should_behave_like "a Place with valid times"

  it "should create a new instance given valid attributes" do
    Place.create!(@valid_attributes)
  end

  it "should not create a new instance without a name" do
    @valid_attributes.delete(:name)
    lambda { Place.create!(@valid_attributes) }.should raise_error
  end

  describe "a Place with no times" do
    before(:each) do
      add_constraint(@place){ false }
      @at = Time.now.midnight + 7.hours
      @open_at = @at.midnight + 7.hours
      @closed_at = @at.midnight + 2.hours
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

  describe "with only special OperatingTimes" do
  end
  describe "with only regular OperatingTimes" do
  end
  describe "with special OperatingTimes overriding regular OperatingTimes" do
  end

  describe "that is currently open" do
    it_should_behave_like "a Place with OperatingTimes"

    before(:each) do
      @at = Time.now.midnight + 7.hours
      @currentSchedule = stub_times([{:start =>  6.hours, :length => 2.hours}])
      @daySchedule = [@currentSchedule]

      @place = Place.create!(@valid_attributes)
      @place.stub(:operating_times).and_return(@currentSchedule)
      @place.stub(:regular_operating_times).and_return(@currentSchedule)
      @place.stub(:special_operating_times).and_return(@currentSchedule)
    end

    it "should produce a valid daySchedule" do
    end

    it "should produce a valid currentSchedule" do
    end

    it "should be open" do
      @place.should_receive(:currentSchedule).
             with(duck_type(:midnight)).
             and_return(@currentSchedule)

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




describe "a capable Place", :shared => true do
  it_can_be "closed all day", "closed for the day", "closed until later today"
  #it_can_be "open past midnight tonight", "open past midnight last night"
  #it_can_be "open now", "closed now"
end

describe "a happy Place" do
  in_order_to_be "closed all day" do

    it "should be closed right now" do
      pending("There ain't no @place to test!") { @place.open?(@at) }
      @place.open?(@at).should == false
    end

    it "should have an empty schedule for the day"
    it "should not have a current schedule"
  end

  in_order_to_be "closed for the day" do
    before(:each) do
    end

    it "should be closed right now"
    it "should not have a current schedule"
    it_can "have no schedule elements later in the day"
    it_can "have schedule elements earlier in the day", "have no schedule elements earlier in the day"
  end

  in_order_to_be "closed until later today" do
    before(:each) do
    end

  end

  in_order_to "have schedule elements earlier in the day" do
  end

  in_order_to "have no schedule elements earlier in the day" do
  end

  in_order_to "have schedule elements later in the day" do
  end

  in_order_to "have no schedule elements later in the day" do
  end

  it_can_be "closed all day", "closed for the day", "closed until later today"

  describe "that has regular times" do
    describe "without special times" do
      it_should_behave_like "a capable Place"
    end

    describe "with special times" do
      describe "overriding the regular times" do
        it_should_behave_like "a capable Place"
      end

      describe "not overriding the regular times" do
        it_should_behave_like "a capable Place"
      end
    end
  end

  describe "that has no regular times" do
    describe "and no special times" do
      it_should_behave_like "a capable Place"
    end

    describe "but has special times" do
      it_should_behave_like "a capable Place"
    end
  end

end
=end
