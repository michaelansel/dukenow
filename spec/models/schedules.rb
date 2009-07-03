######################
##### Scheduling #####
######################

ConstraintDebugging = false

def add_constraint(place, &block)
  place.constraints ||= []
  place.constraints << block
end

# Test +time+ against all constraints for +place+
def acceptable_time(place, time)
  if ConstraintDebugging
    puts "Testing Time: #{time.inspect}"
  end

  matched_all = true
  place.constraints.each do |c|
    matched = c.call(time)

    if ConstraintDebugging
      if matched
        puts "++ Time accepted by constraint"
      else
        puts "-- Time rejected by constraint"
      end
      puts "     Constraint: #{c.to_s.sub(/^[^\@]*\@/,'')[0..-2]}"
    end

    matched_all &= matched
  end

  if ConstraintDebugging
    if matched_all
      puts "++ Time Accepted"
    else
      puts "-- Time Rejected"
    end
    puts ""
  end

  matched_all
end

def add_times(place, times = [])
  times.each do |t|
    unless t[:start] and t[:length]
      raise ArgumentError, "Must specify a valid start offset and length"
    end

    if acceptable_time(place, t)
      t[:override]   ||= false
      t[:startDate]  ||= Date.yesterday
      t[:endDate]    ||= Date.tomorrow
      t[:daysOfWeek] ||= OperatingTime::ALL_DAYS
      t[:place_id]   ||= place.id
      ot = OperatingTime.new
      t.each{|k,v| ot.send(k.to_s+'=',v)}

      puts "Added time: #{ot.inspect}" if ConstraintDebugging

      if t[:override]
        place.special_operating_times << ot
      else
        place.regular_operating_times << ot
      end

    end
  end

  if ConstraintDebugging
    puts "Regular Times: #{place.regular_operating_times.inspect}"
    puts "Special Times: #{place.special_operating_times.inspect}"
  end

  place
end

def remove_times(place, times = [])
end


describe "a Place with scheduling capabilities", :shared => true do

  in_order_to "be open now" do
    before(:each) do
      add_times(@place,[
        {:start => 6.hours, :length => 2.hours, :override => false},
        {:start => 6.hours, :length => 2.hours, :override => true}
      ])
      @at = Time.now.midnight + 7.hours
    end

    it "should have a schedule" do
      @place.operating_times.should_not be_empty
      @place.schedule(@at.midnight, @at.midnight + 1.day).should_not be_empty
      @place.daySchedule(@at).should_not be_empty
      @place.currentSchedule(@at).should_not be_nil
    end

    it "should be open today" do
      @place.open(@at).should == true
    end

    it "should be open in the past" do
    end

    it "should be open in the future" do
    end
  end

  in_order_to "be open 24 hours" do
  end

  in_order_to "be open later in the day" do
    before(:each) do
      add_times(@place,[
        {:start => 16.hours, :length => 2.hours, :override => false},
        {:start => 16.hours, :length => 2.hours, :override => true}
      ])
      @at = Time.now.midnight + 12.hours
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
    end
  end

  in_order_to "be open past midnight (last night)" do
  end


  in_order_to "be closed now" do
    before(:each) do
      #add_constraint(@place) {|t| (  t[:start] > (@at - @at.midnight) ) or
                                  #( (t[:start] + t[:length]) < (@at - @at.midnight) ) }
      add_times(@place,[
        {:start => 6.hours, :length => 2.hours, :override => false},
        {:start => 6.hours, :length => 2.hours, :override => true}
      ])
      @at = Time.now.midnight + 9.hours
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
  before(:each) do
    add_constraint(@place) { true }
  end

  describe "with only regular times" do
    before(:each) do
      add_constraint(@place) {|t| t[:override] == false }
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
    #it_can "be open 24 hours"
    #it_can "be open later in the day"
    #it_can "be open earlier in the day"
    #it_can "be open past midnight (tonight)"
    #it_can "be open past midnight (last night)"

    #it_can "be closed now"
    #it_can "be closed all day"
    #it_can "be closed for the day"
    #it_can "be closed until later in the day"

  end

  describe "with only special times" do
    before(:each) do
      add_constraint(@place) {|t| t[:override] == true }
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
    #it_can "be open 24 hours"
    #it_can "be open later in the day"
    #it_can "be open earlier in the day"
    #it_can "be open past midnight (tonight)"
    #it_can "be open past midnight (last night)"

    #it_can "be closed now"
    #it_can "be closed all day"
    #it_can "be closed for the day"
    #it_can "be closed until later in the day"

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



