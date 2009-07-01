require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def add_constraint(place, &block)
  place.constraints ||= []
  place.constraints << block
end

def add_times(place, times = [])
  times.each do |t|
    place.constraints.each do |c|
      if c.call(t) # If it matches the constraint

        ot = mock_model(OperatingTime)
        ot.stub(:start).and_return(t[:start])
        ot.stub(:length).and_return(t[:length])
        ot.stub(:override).and_return(t[:override] || 0)
        ot.stub(:startDate).and_return(t[:startDate] || Date.yesterday)
        ot.stub(:endDate).and_return(t[:endDate] || Date.tomorrow)
        ot.stub(:flags).and_return(t[:flags] || OperatingTime::ALL_DAYS)
        ot.stub(:place_id).and_return(place.id)
        ot.should_receive(:to_times).any_number_of_times do |at|
          at.should respond_to(:midnight)

          open = at.midnight + ot.start
          close = open + ot.length
          [open,close]
        end

        if t[:override]
          place.special_operating_times << ot
        else
          place.regular_operating_times << ot
        end

      end
    end
  end
end

def remove_times(place, times = [])
end

def build_place_from_times(times = [])
  place = Place.create!(@valid_attributes)

  regularTimes,specialTimes = stub_times(times, place.id)

  place.stub(:operating_times).and_return(regularTimes + specialTimes)
  place.stub(:regular_operating_times).and_return(regularTimes)
  place.stub(:special_operating_times).and_return(specialTimes)

  place
end

def stub_times(times = [], place_id = 0)
  regularTimes = []
  specialTimes = []

  times.each do |time|
    ot = mock_model(OperatingTime)
    ot.stub(:start).and_return(time[:start])
    ot.stub(:length).and_return(time[:length])
    ot.stub(:override).and_return(time[:override] || 0)
    ot.stub(:startDate).and_return(time[:startDate] || Date.yesterday)
    ot.stub(:endDate).and_return(time[:endDate] || Date.tomorrow)
    ot.stub(:flags).and_return(time[:flags] || OperatingTime::ALL_DAYS)
    ot.stub(:place_id).and_return(place_id)
    ot.should_receive(:to_times).any_number_of_times do |at|
      at.should respond_to(:midnight)

      open = at.midnight + ot.start
      close = open + ot.length
      [open,close]
    end

    if time.keys.include?(:override) and time[:override] == 1
      specialTimes << ot
    elsif time[:override].nil? or time[:override] == 0
      regularTimes << ot
    end
  end

  [regularTimes,specialTimes]
end

describe "a Place with scheduling capabilities", :shared => true do

  in_order_to "be open now" do
    it "should be open" do
      @place.open(@open_at).should == true
    end
  end

  in_order_to "be open 24 hours" do
  end

  in_order_to "be open later in the day" do
    it "should have a schedule between now and midnight" do
      @place.schedule(@at,@at.midnight + 24.hours).size.should > 0
    end
  end

  in_order_to "be open earlier in the day" do
  end

  in_order_to "be open past midnight (tonight)" do
  end

  in_order_to "be open past midnight (last night)" do
  end


  in_order_to "be closed now" do
    it "should be closed" do
      @place.open(@closed_at).should == false
    end
  end

  in_order_to "be closed all day" do
  end

  in_order_to "be closed for the day" do
  end

  in_order_to "be closed until later in the day" do
  end

  in_order_to "have a valid schedule" do
    it "should not have any overlapping times"
    it "should have all times within the specified time range"
  end
end

describe "a Place with all scheduling capabilities", :shared => true do
  it_can "be open now"
  it_can "be open 24 hours"
  it_can "be open later in the day"
  it_can "be open earlier in the day"
  it_can "be open past midnight (tonight)"
  it_can "be open past midnight (last night)"

  it_can "be closed now"
  it_can "be closed all day"
  it_can "be closed for the day"
  it_can "be closed until later in the day"
end

describe "a Place with no times", :shared => true do
  before(:each) do
    add_constraint(@place){ false }
    @at = Time.now.midnight + 7.hours
    @open_at = @at.midnight + 7.hours
    @closed_at = @at.midnight + 2.hours
  end

  it_should_behave_like "a Place with scheduling capabilities"
  it_can "be closed now", "be closed all day", "be closed for the day"
end

describe "a Place with valid times", :shared => true do
  before(:each) do
    add_constraint(@place) { true }
=begin
    add_times([{:start => 6.hours, :length => 2.hours}])
    @at = Time.now.midnight + 7.hours
    @open_at = @at.midnight + 7.hours
    @closed_at = @at.midnight + 2.hours
=end
  end

  it_should_behave_like "a Place with scheduling capabilities"

  describe "with only regular times" do
    before(:each) do
      add_constraint(@place) {|t| not t[:override]}
      add_times(@place,
                   [{:start => 6.hours, :length => 2.hours},
                    {:start => 12.hours, :length => 6.hours},
                    {:start => 20.hours, :length => 3.hours}]
      )
      @open_at = @at.midnight + 7.hours
      @closed_at = @at.midnight + 2.hours
    end

    it_should_behave_like "a Place with all scheduling capabilities"
  end

  describe "with only special times" do
    #it_should_behave_like "a Place with all scheduling capabilities"
  end

  describe "with regular and special times" do
    describe "where the special times are overriding the regular times" do
      #it_should_behave_like "a Place with all scheduling capabilities"
    end

    describe "where the special times are not overriding the regular times" do
      #it_should_behave_like "a Place with all scheduling capabilities"
    end
  end


  describe "with special times" do
    describe "extending normal hours" do
      #it_should_behave_like "a Place with all scheduling capabilities"
    end

    describe "reducing normal hours" do
      #it_should_behave_like "a Place with all scheduling capabilities"
    end

    describe "removing all hours" do
      #it_should_behave_like "a Place with all scheduling capabilities"
    end

    describe "moving normal hours (extending and reducing)" do
      #it_should_behave_like "a Place with all scheduling capabilities"
    end
  end
end


describe Place do
  before(:each) do
    @valid_attributes = {
      :name => 'Test Place',
      :location => 'Somewhere',
      :phone => '(919) 555-1212'
    }

    @place = Place.create!(@valid_attributes)
    @place.class_eval("attr_accessor :constraints")

    @place.stub(:regular_operating_times).and_return([])
    @place.stub(:special_operating_times).and_return([])
  end

  it_should_behave_like "a Place with no times"
  it_should_behave_like "a Place with valid times"

  it "should create a new instance given valid attributes" do
    Place.create!(@valid_attributes)
  end

  it "should not create a new instance without a name" do
    @valid_attributes.delete(:name)
    lambda { Place.create!(@valid_attributes) }.should raise_error
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
