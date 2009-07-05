require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OperatingTime do
  before(:each) do
    @place = mock_model(Place)
    @valid_attributes = {
      :place_id   => @place.id,
      :start      => (Time.now - 1.hours).to_i,
      :length     => 2.hours,
      :daysOfWeek => OperatingTime::ALL_DAYS,
      :startDate  => Date.yesterday,
      :endDate    => Date.tomorrow,
      :override   => false
    }
    @operating_time = OperatingTime.create!(@valid_attributes)
  end

  it "should create a new instance given all valid attributes" do
    OperatingTime.create!(@valid_attributes)
  end

  describe "missing required attributes" do
    it "should not create a new instance without a valid start time"
    it "should not create a new instance without a valid length"
    it "should not create a new instance without a valid Place reference"
    it "should not create a new instance without a valid start date"
    it "should not create a new instance without a valid end date"
  end

  describe "missing default-able attributes" do
    it "should default daysOfWeek to 0" do
      @valid_attributes.delete(:daysOfWeek) if @valid_attributes[:daysOfWeek]
      OperatingTime.create!(@valid_attributes).daysOfWeek.should == 0
    end

    it "should default override to false" do
      @valid_attributes.delete(:override) if @valid_attributes[:override]
      OperatingTime.create!(@valid_attributes).override.should == false
    end
  end

  describe "given invalid attributes" do
    def create
      @operating_time = OperatingTime.create!(@valid_attributes)
    end

=begin
    it "should create a new instance, but ignore an invalid override value" do
      @valid_attributes[:override] = "invalid"
      create
      @operating_time.override.should == false # where false is the default value

      @valid_attributes[:override] = 10
      create
      @operating_time.override.should == false # where false is the default value
    end

    it "should create a new instance, but ignore an invalid daysOfWeek value" do
      @valid_attributes[:daysOfWeek] = 1000
      create
      @operating_time.daysOfWeek.should == 0 # where 0 is the default value
    end
=end

    it "should not create a new instance with an invalid start time"
    it "should not create a new instance with an invalid length"
    it "should not create a new instance with an invalid Place reference"
    it "should not create a new instance with an invalid start date"
    it "should not create a new instance with an invalid end date"
  end

  it "should enable override mode" do
    @operating_time.should_receive(:write_attribute).with(:override, true).exactly(3).times
    @operating_time.override = true
    @operating_time.override = "true"
    @operating_time.override = 1
  end

  it "should disable override mode" do
    @operating_time.should_receive(:write_attribute).with(:override, false).exactly(3).times
    @operating_time.override = false
    @operating_time.override = "false"
    @operating_time.override = 0
  end

  it "should complain about invalid override values, but not change the value" do
    @operating_time.override = true
    @operating_time.override.should == true

    #TODO Should nil be ignored or errored?
    lambda { @operating_time.override = nil }.should raise_error(ArgumentError)
    @operating_time.override.should == true

    lambda { @operating_time.override = "invalid" }.should raise_error(ArgumentError)
    @operating_time.override.should == true

    lambda { @operating_time.override = false }.should_not raise_error
    @operating_time.override.should == false
  end

  it "should complain about invalid daysOfWeek values, but not change the value" do
    @operating_time.daysOfWeek = OperatingTime::SUNDAY
    @operating_time.daysOfWeek.should == OperatingTime::SUNDAY

    #TODO Should nil be ignored or errored?
    lambda { @operating_time.daysOfWeek = nil }.should raise_error(ArgumentError)
    @operating_time.daysOfWeek.should == OperatingTime::SUNDAY

    lambda { @operating_time.daysOfWeek = 200 }.should raise_error(ArgumentError)
    @operating_time.daysOfWeek.should == OperatingTime::SUNDAY

    lambda { @operating_time.daysOfWeek= OperatingTime::MONDAY }.should_not raise_error
    @operating_time.daysOfWeek.should == OperatingTime::MONDAY
  end

  describe "with open and close times" do
    before(:each) do
      @now = Time.now.midnight + 15.minutes

      @open  = @now.midnight + 23.hours + 30.minutes
      @close = @open + 1.hour

      start = @open - @open.midnight
      length = @close - @open
      @valid_attributes.update({
        :start => start,
        :length  => length
      })
      @operating_time = OperatingTime.create!(@valid_attributes)
    end

    it "should return valid open and close times for 'now'" do
      open,close = @operating_time.next_times()
      open.to_s.should == @open.to_s
      close.to_s.should == @close.to_s
    end

    it "should return valid open and close times for a given time" do
      @open, @close, @now = [@open,@close,@now].collect{|t| t + 5.days}
      @operating_time.endDate += 5

      open,close = @operating_time.next_times( @now )
      open.to_s.should == @open.to_s
      close.to_s.should == @close.to_s
    end
  end
end



### Midnight Module Specs ###

describe Date do
  before(:each) do
    @date = Date.today
  end

  it "should have a valid midnight" do
    @date.should respond_to(:midnight)
    @date.midnight.should == Time.mktime(@date.year, @date.month, @date.day, 0, 0, 0)
  end
end

describe Time do
  before(:each) do
    @time = Time.now
  end

  it "should have a valid midnight" do
    @time.should respond_to(:midnight)
    @time.midnight.should == Time.mktime(@time.year, @time.month, @time.day, 0, 0, 0)
  end

  it "should have a valid midnight offset" do
    @time.should respond_to(:offset)
    @time.offset.should == @time.hour.hours + @time.min.minutes + @time.sec
  end
end

describe DateTime do
  before(:each) do
    @dt = DateTime.now
  end

  it "should have a valid midnight" do
    @dt.should respond_to(:midnight)
    @dt.midnight.should == Time.mktime(@dt.year, @dt.month, @dt.day, 0, 0, 0)
  end
end

### End Midnight Module Specs ###
