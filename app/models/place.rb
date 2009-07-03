class Place < ActiveRecord::Base
  DEBUG = defined? DEBUG ? DEBUG : false

  has_many :operating_times
  acts_as_taggable_on :tags
  validates_presence_of :name

  def special_operating_times
    OperatingTime.find( :all, :conditions => {:place_id => id, :override => 1}, :order => "startDate ASC, opensAt ASC" )
  end

  def regular_operating_times
    OperatingTime.find( :all, :conditions => {:place_id => id, :override => 0}, :order => "startDate ASC, opensAt ASC" )
  end

  # Returns an array of OperatingTimes
  def schedule(startAt,endAt)
    # TODO Returns the schedule for a specified time window
    # TODO Handle events starting within the range but ending outside of it?

    # TODO Offload this selection to the database; okay for testing
    regular_operating_times = regular_operating_times().select{|t| t.startDate <= endAt.to_date and t.endDate >= startAt.to_date}
    special_operating_times = special_operating_times().select{|t| t.startDate <= endAt.to_date and t.endDate >= startAt.to_date}

    regular_times  = []
    special_times  = []
    special_ranges = []

    special_operating_times.each do |ot|
      puts "\nSpecial Scheduling: #{ot.inspect}" if DEBUG

      open,close = ot.next_times(startAt-1.day)
      next if open.nil? # No valid occurrences in the future

      while not open.nil? and open <= endAt do
        if DEBUG
          puts "Open: #{open}"
          puts "Close: #{close}"
          puts "Start Date: #{ot.startDate} (#{ot.startDate.class})"
          puts "End Date: #{ot.endDate} (#{ot.endDate.class})"
        end

        special_times << [open,close]
        special_ranges << Range.new(ot.startDate,ot.endDate)
        open,close = ot.next_times(close)
      end

    end

    puts "\nSpecial Times: #{special_times.inspect}" if DEBUG
    puts "\nSpecial Ranges: #{special_ranges.inspect}" if DEBUG

    regular_operating_times.each do |ot|
      puts "\nRegular Scheduling: #{ot.inspect}" if DEBUG

      open,close = ot.next_times(startAt-1.day)
      next if open.nil? # No valid occurrences in the future

      while not open.nil? and open <= endAt do
        puts "Open: #{open}" if DEBUG
        puts "Close: #{close}" if DEBUG

        special_ranges.each do |sr|
          next if sr.member?(open)
        end

        regular_times << [open,close]
        open,close = ot.next_times(close)
      end

    end

    puts "\nRegular Times: #{regular_times.inspect}" if DEBUG

    # TODO Handle schedule overrides
    # TODO Handle combinations (i.e. part special, part regular)

    (regular_times+special_times).sort{|a,b|a[0] <=> b[0]}
  end

  def daySchedule(at = Date.today)
    at = at.to_date if at.class == Time or at.class == DateTime

    schedule = schedule(at.midnight,(at+1).midnight)
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

    schedule.sort{|a,b|a[0] <=> b[0]}
  end

  def currentSchedule(at = Time.now)
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

  # Alias for <tt>open?</tt>
  def open(at = Time.now); open? at ; end

  def to_json(params)
    super(params.merge({:only => [:id, :name, :location, :phone], :methods => [ :open ]}))
  end
  def to_xml(params)
    super(params.merge({:only => [:id, :name, :location, :phone], :methods => [ :open ]}))
  end
end
