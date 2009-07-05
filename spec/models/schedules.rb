######################
##### Scheduling #####
######################



describe "a Place with scheduling capabilities", :shared => true do
  before(:each) do
    add_scheduling_spec_helpers(@place)
  end

  it "should be clean" do
    @place.regular_operating_times.should == []
    @place.special_operating_times.should == []
    @place.constraints.should == []
    @place.times.should == []
  end

  in_order_to "be open now" do
    describe "can be open now, so" do
    before(:each) do
      @place.add_times([
        {:start => 6.hours, :length => 2.hours, :override => false},
        {:start => 6.hours, :length => 2.hours, :override => true}
      ])
      @at = (@at || Time.now).midnight + 7.hours

      @place.build
    end

    it "should have operating times" do
      @place.operating_times.should_not be_empty
    end

    it "should have a schedule" do
      @place.schedule(@at.midnight, @at.midnight + 1.day).should_not be_empty
    end

    it "should have a daySchedule" do
      @place.daySchedule(@at).should_not be_empty
    end

    it "should have a currentSchedule" do
      #puts "\n\n\n\n\n\nDay Schedule: \n#{@place.daySchedule(@at).collect{|a,b| a.inspect + " to " + b.inspect}.join("\n")}\n\n\n\n\n\n"
      @place.currentSchedule(@at).should_not be_nil
    end

    it "should be open today" do
      @place.open(@at).should == true
    end

    it "should be open \"now\" in the past" do
      @at -= 12.days
      @place.operating_times.each do |t|
        t.startDate -= 12
      end

      @place.open(@at).should == true
    end

    it "should be open \"now\" in the future" do
      @at += 12.days
      @place.operating_times.each do |t|
        t.endDate += 12
      end

      @place.open(@at).should == true
    end
    end
  end

  in_order_to "be open 24 hours" do
    before(:each) do
      @place.add_times([
        {:start => 0, :length => 24.hours, :override => false},
        {:start => 0, :length => 24.hours, :override => true}
      ])
      @at = Time.now.midnight + 12.hours

      @place.build
    end

    it "should be open during the day" do
      @place.open(@at).should == true
    end

    it "should be open at midnight" do
      @place.open(@at.midnight).should == true
    end
  end

  in_order_to "be open later in the day" do
    before(:each) do
      @place.add_times([
        {:start => 16.hours, :length => 2.hours, :override => false},
        {:start => 16.hours, :length => 2.hours, :override => true}
      ])
      @at = Time.now.midnight + 12.hours

      @place.build
    end

    it "should have a schedule between now and midnight" do
      @place.schedule(@at,@at.midnight + 24.hours).size.should > 0
    end
  end

  in_order_to "be open earlier in the day" do
  end

  in_order_to "be open past midnight (tonight)" do
    before(:each) do
      @at = Time.now.midnight

      @place.build
    end
  end

  in_order_to "be open past midnight (last night)" do
  end


  in_order_to "be closed now" do
    before(:each) do
      @place.add_constraint {|t| (  t[:start] > @at.offset ) or
                                 ( (t[:start] + t[:length]) < @at.offset ) }
      @place.add_times([
        {:start => 6.hours, :length => 2.hours, :override => false},
        {:start => 6.hours, :length => 2.hours, :override => true}
      ])
      @at = Time.now.midnight + 12.hours

      @place.build
    end

    it "should be closed" do
      @place.open(@at).should == false
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

describe "a Place with valid times", :shared => true do
  describe "with only regular times" do
    before(:each) do
      @place.add_constraint {|t| t[:override] == false }

      @place.build
    end

    validate_setup do
      it "should have regular times" do
        #puts "Regular Times: #{@place.regular_operating_times.inspect}"
        @place.regular_operating_times.should_not be_empty
      end

      it "should not have any special times" do
        #puts "Special Times: #{@place.special_operating_times.inspect}"
        @place.special_operating_times.should be_empty
      end
    end

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

  describe "with only special times" do
    before(:each) do
      @place.add_constraint {|t| t[:override] == true }

      @place.build
    end


    validate_setup do
      it "should not have regular times" do
        @place.regular_operating_times.should be_empty
      end

      it "should have special times" do
        @place.special_operating_times.should_not be_empty
      end
    end

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

  describe "with regular and special times" do
    validate_setup do
      it "should have regular times" do
        @place.regular_operating_times.should_not be_empty
      end

      it "should have special times" do
        @place.special_operating_times.should_not be_empty
      end
    end

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
