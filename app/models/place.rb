class Place < ActiveRecord::Base
  DEBUG = false

  has_many :operating_times
  has_one :dining_extension
  acts_as_taggable_on :tags
  validates_presence_of :name

  def special_operating_times
    OperatingTime.find( :all, :conditions => {:place_id => id, :override => 1})
  end

  def regular_operating_times
    OperatingTime.find( :all, :conditions => {:place_id => id, :override => 0})
  end

  # Returns an array of Times representing the opening and closing times
  # of this Place between +startAt+ and +endAt+
  def schedule(startAt,endAt)
    ## Caching ##
    @schedules ||= {}
    if @schedules[startAt.xmlschema] and
       @schedules[startAt.xmlschema][endAt.xmlschema]
      return @schedules[startAt.xmlschema][endAt.xmlschema]
    end
    ## End Caching ##

    # TODO Handle events starting within the range but ending outside of it?

    # TODO Offload this selection to the database; okay for testing though
    # Select all relevant times (1 day buffer on each end)
    # NOTE Make sure to use generous date comparisons to allow for midnight rollovers
    all_regular_operating_times = regular_operating_times().select{|t| (t.startDate - 1) <= endAt.to_date and startAt.to_date <= (t.endDate + 1)}
    all_special_operating_times = special_operating_times().select{|t| (t.startDate - 1) <= endAt.to_date and startAt.to_date <= (t.endDate + 1)}

    puts "\nRegular OperatingTimes: #{all_regular_operating_times.inspect}" if DEBUG
    puts "\nSpecial OperatingTimes: #{all_special_operating_times.inspect}" if DEBUG

    regular_times  = []
    special_times  = []
    special_ranges = []

    all_special_operating_times.each do |ot|
      puts "\nSpecial Scheduling for: #{ot.inspect}" if DEBUG

      # Start a day early if possible
      earlyStart = startAt-1.day < ot.startDate.midnight ? startAt : startAt - 1.day
      # Calculate the next set up open/close times
      open,close = ot.next_times(earlyStart)
      next if open.nil? # No valid occurrences in the future

      while not open.nil? and open <= endAt do
        if DEBUG
          puts "Open: #{open}"
          puts "Close: #{close}"
          puts "Start Date: #{ot.startDate} (#{ot.startDate.class})"
          puts "End Date: #{ot.endDate} (#{ot.endDate.class})"
        end

        if close < startAt # Skip forward to the first occurrance in our time range
          open,close = ot.next_times(close)
          next
        end

        special_times << [open,close]
        special_ranges << Range.new(ot.startDate,ot.endDate)
        open,close = ot.next_times(close)
      end

    end

    puts "\nSpecial Times: #{special_times.inspect}" if DEBUG
    puts "\nSpecial Ranges: #{special_ranges.inspect}" if DEBUG

    all_regular_operating_times.each do |ot|
      puts "\nRegular Scheduling for: #{ot.inspect}" if DEBUG

      # Start a day early if possible
      earlyStart = startAt-1.day < ot.startDate.midnight ? startAt : startAt - 1.day
      # Calculate the next set up open/close times
      open,close = ot.next_times(earlyStart)
      next if open.nil? # No valid occurrences in the future

      while not open.nil? and open <= endAt do
        puts "Open: #{open}" if DEBUG
        puts "Close: #{close}" if DEBUG

        if close < startAt # Skip forward to the first occurrance in our time range
          open,close = ot.next_times(close)
          next
        end

        special_ranges.each do |sr|
          next if sr.member?(open)
        end

        # FIXME Causing an infinite loop; would be nice if this worked
        #open = startAt if open < startAt
        #close = endAt if close > endAt

        regular_times << [open,close]
        open,close = ot.next_times(close)
      end

    end

    puts "\nRegular Times: #{regular_times.inspect}" if DEBUG

    # TODO Handle schedule overrides
    # TODO Handle combinations (i.e. part special, part regular)

    final_schedule = (regular_times+special_times).sort{|a,b|a[0] <=> b[0]}

    ## Caching ##
    @schedules ||= {}
    @schedules[startAt.xmlschema] ||= {}
    @schedules[startAt.xmlschema][endAt.xmlschema] = final_schedule
    ## End Caching ##

    final_schedule
  end

  def daySchedule(at = Date.today)
    at = at.to_date if at.class == Time or at.class == DateTime

    day_schedule = schedule(at.midnight,(at+1).midnight)
    #schedule = schedule.select {|ot| (ot.flags & 1<<at.wday) > 0 }
    #schedule.each {|t| t.at = at }

=begin
    # Find all operating times for this place that are:
    # - Special
    # - Are effective on date "at" (between startDate and endDate)
    # - Are effective on weekday "at.wday"
    schedule = OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) > 0 and (flags & ?) > 0 and startDate <= ? and endDate >= ?", id, 1 << at.wday, at.to_s, at.to_s] )

    # If we don't have any special operating times
    if schedule == []
    # Find all operating times for this place that are:
    # - NOT Special
    # - Are effective on weekday "at.wday"
      schedule = OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) == 0 and (flags & ?) > 0", id, 1 << at.wday] )
    end
=end

    day_schedule.sort{|a,b|a[0] <=> b[0]}
  end

  def currentSchedule(at = Time.now)
    puts "At(cS): #{at}" if DEBUG
    daySchedule(at).select { |open,close|
      puts "Open(cS): #{open}" if DEBUG
      puts "Close(cS): #{close}" if DEBUG
      open <= at and at <= close
    }[0]
  end

  def open?(at = Time.now)
    a = currentSchedule(at)
    return a ? true : false
  end
  alias :open :open?

  def to_json(params)
    super(params.merge({:only => [:id, :name, :location, :phone], :methods => [ :open ]}))
  end
  def to_xml(options = {})
    #super(options.merge({:only => [:id, :name, :location, :phone], :methods => [ :open, :daySchedule ] }))
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.place do

      xml.id(self.id)
      xml.name(self.name)
      xml.location(self.location)
      xml.building_id(self.building_id)
      xml.phone(self.phone)
      xml.tags do |xml|
        self.tag_list.each do |tag|
          xml.tag(tag)
        end
      end

      self.dining_extension.to_xml(options) unless self.dining_extension.nil?

      xml.open(self.open?)

      if daySchedule.nil? or daySchedule.empty?
        xml.daySchedule
      else
        xml.daySchedule(:for => Date.today) do |xml|; daySchedule.each do |open,close|
            xml.open(open.xmlschema)
            xml.close(close.xmlschema)
        end; end
      end

    end
  end
end
