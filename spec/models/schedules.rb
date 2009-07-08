######################
##### Scheduling #####
######################



describe "a Place with scheduling capabilities", :shared => true do
  before(:each) do
    add_scheduling_spec_helpers(@place)
  end

  validate_setup do
    before(:each) do
      @place.build(@at || Time.now)
    end
  end

  it "should be clean" do
    @place.regular_operating_times.should == []
    @place.special_operating_times.should == []
    @place.constraints.should == []
    @place.times.should == []
  end

  in_order_to "be open now" do
    before(:each) do
      @place.add_times([
        {:start => 6.hours, :length => 2.hours, :override => false},
        {:start => 6.hours, :length => 2.hours, :override => true}
      ])
      @at = @at || (Time.now.midnight + 7.hours)
    end

    it "should have operating times" do
      @place.build(@at)
      @place.operating_times.should_not be_empty
    end

    it "should have a schedule" do
      @place.build(@at)
      @place.schedule(@at.midnight, @at.midnight + 1.day).should_not be_empty
    end

    it "should have a daySchedule" do
      @place.build(@at)
      @place.daySchedule(@at).should_not be_empty
    end

    it "should have a currentSchedule" do
      @place.build(@at)
      @place.currentSchedule(@at).should_not be_nil
    end

    it "should be open on Sunday" do
      @at = @at - @at.wday.days # Set to previous Sunday
      @place.rebuild(@at)

      @place.open(@at).should == true
    end

    it "should be open on Wednesday" do
      @at = @at - @at.wday.days + 3.days # Set to Wednesday after last Sunday
      @place.rebuild(@at)

      begin
        @place.open(@at).should == true
      rescue Exception => e
        puts ""
        puts "At: #{@at}"
        puts "Times: #{@place.times.inspect}"
        puts "OperatingTimes: #{@place.operating_times.inspect}"
        puts "daySchedule: #{@place.daySchedule(@at)}"

        raise e
      end
    end

    it "should be open on Saturday" do
      @at = @at - @at.wday.days + 6.days# Set to Saturday after last Sunday
      @place.rebuild(@at)

      @place.open(@at).should == true
    end

    it "should be open on only one day every week" do
      @at = @at - @at.wday.days + 6.days# Set to Saturday after last Sunday
      @place.times.each do |t|
        t[:days_of_week] = OperatingTime::SATURDAY
        t[:startDate]  = @at.to_date - 2.days
        t[:endDate]  = @at.to_date + 3.weeks
      end
      @place.rebuild(@at)

      @place.schedule(@at-1.day, @at+15.days).should have(3).times
      @place.schedule(@at-1.day, @at+15.days).collect{|a,b|[a.xmlschema,b.xmlschema]}.uniq.should have(3).unique_times
    end
  end

  in_order_to "be open 24 hours" do
    before(:each) do
      @place.add_times([
        {:start => 0, :length => 24.hours, :override => false},
        {:start => 0, :length => 24.hours, :override => true}
      ])
      @at = @at || (Time.now.midnight + 12.hours)

      @place.build(@at)
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
      @at = @at || (Time.now.midnight + 12.hours)

      @place.build(@at)
    end

    it "should be closed now" do
      @place.open(@at).should == false
    end

    it "should have a schedule later in the day" do
      @place.schedule(@at,@at.midnight + 24.hours).should_not be_empty
    end

    it "should not have a schedule earlier in the day" do
      @place.schedule(@at.midnight,@at).should be_empty
    end
  end

  in_order_to "be closed for the day" do
    before(:each) do
      @place.add_times([
        {:start => 4.hours, :length => 2.hours, :override => false},
        {:start => 4.hours, :length => 2.hours, :override => true}
      ])
      @at = @at || (Time.now.midnight + 12.hours)
      @place.build(@at)
    end

    it "should be closed now" do
      @place.open(@at).should == false
    end

    it "should have a schedule earlier in the day" do
      @place.schedule(@at.midnight,@at).should_not be_empty
    end

    it "should not have a schedule later in the day" do
      @place.schedule(@at, @at.midnight + 24.hours).should be_empty
    end
  end

  in_order_to "be open past midnight" do
    before(:each) do
      @at = @at || (Time.now.midnight + 12.hours)

      @place.add_times([
        {:start => 23.hours, :length => 4.hours, :override => true},
        {:start => 23.hours, :length => 4.hours, :override => false}
      ])

      @place.times.each do |t|
        t[:startDate] = @at.to_date
        t[:endDate] = @at.to_date
      end

      @place.build(@at)
    end

    it "should be open early the next morning" do
      @place.open(@at.midnight + 1.days + 2.hours).should == true
    end

    it "should not be open early that morning" do
      @place.open(@at.midnight + 2.hours).should == false
    end

    it "should not be open late the next night" do
      @place.open(@at.midnight + 2.days + 2.hours).should == false
    end
  end

  in_order_to "be closed now" do
    before(:each) do
      @place.add_constraint {|t| (  t[:start] > @at.offset ) or
                                 ( (t[:start] + t[:length]) < @at.offset ) }
      @place.add_times([
        {:start => 6.hours, :length => 2.hours, :override => false},
        {:start => 6.hours, :length => 2.hours, :override => true}
      ])
      @at = @at || (Time.now.midnight + 12.hours)

      @place.build(@at)
    end

    it "should be closed" do
      @place.open(@at).should == false
    end
  end

  in_order_to "be closed all day" do
    before(:each) do
      @at ||= Time.now

      @place.add_times([
        {:start => 0, :length => 0, :startDate => @at.to_date, :endDate => @at.to_date, :override => false},
        {:start => 0, :length => 0, :startDate => @at.to_date, :endDate => @at.to_date, :override => true}
      ])

      @place.build(@at)
    end

    it "should be closed now" do
      @place.open(@at).should == false
    end

    it "should not have a schedule earlier in the day" do
      @place.schedule(@at.midnight,@at).should be_empty
    end

    it "should not have a schedule later in the day" do
      @place.schedule(@at, @at.midnight + 24.hours).should be_empty
    end

    it "should not have a schedule at all for the day" do
      @place.daySchedule(@at).should be_empty
    end
  end

  in_order_to "have a valid schedule" do
    it "should not have any overlapping times"
    it "should have all times within the specified time range"
  end
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
    it_can "be open past midnight"
    it_can "be open later in the day"
    it_can "be closed for the day"
    it_can "be closed now"
    it_can "be closed all day"

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
    it_can "be open past midnight"
    it_can "be open later in the day"
    it_can "be closed for the day"
    it_can "be closed now"
    it_can "be closed all day"

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
      #it_can "be open now"
      #it_can "be open 24 hours"
      #it_can "be open past midnight"
      #it_can "be open later in the day"
      #it_can "be closed for the day"
      #it_can "be closed now"
      #it_can "be closed all day"
    end

    describe "where the special times are not overriding the regular times" do
      #it_can "be open now"
      #it_can "be open 24 hours"
      #it_can "be open past midnight"
      #it_can "be open later in the day"
      #it_can "be closed for the day"
      #it_can "be closed now"
      #it_can "be closed all day"
    end
  end


  describe "with special times" do
    describe "extending normal hours" do
      #it_can "be open now"
      #it_can "be open 24 hours"
      #it_can "be open past midnight"
      #it_can "be open later in the day"
      #it_can "be closed for the day"
      #it_can "be closed now"
      #it_can "be closed all day"
    end

    describe "reducing normal hours" do
      #it_can "be open now"
      #it_can "be open 24 hours"
      #it_can "be open past midnight"
      #it_can "be open later in the day"
      #it_can "be closed for the day"
      #it_can "be closed now"
      #it_can "be closed all day"
    end

    describe "removing all hours" do
      before(:each) do
        @at = @at || (Time.now.midnight + 8.hours)

        @place.add_times([
          {:start => 6.hours, :length => 9.hours, :override => false},
          {:start => 0, :length => 0, :override => true, :startDate => @at.to_date, :endDate => @at.to_date}
        ])

        @place.build(@at)
      end
      it_can "be closed now"
      it_can "be closed all day"
    end

    describe "moving normal hours (extending and reducing)" do
      #it_can "be open now"
      #it_can "be open 24 hours"
      #it_can "be open past midnight"
      #it_can "be open later in the day"
      #it_can "be closed for the day"
      #it_can "be closed now"
      #it_can "be closed all day"
    end
  end
end
