class OperatingTime < ActiveRecord::Base
  belongs_to :place
  acts_as_taggable_on :operating_time_tags
  validates_presence_of :place_id, :endDate, :startDate
  validates_associated :place
  validate :end_after_start, :daysOfWeek_valid
  validate {|ot| 0 <= ot.length and ot.length <= 1.days }

  ## DaysOfWeek Constants ##
  SUNDAY    = 0b00000001
  MONDAY    = 0b00000010
  TUESDAY   = 0b00000100
  WEDNESDAY = 0b00001000
  THURSDAY  = 0b00010000
  FRIDAY    = 0b00100000
  SATURDAY  = 0b01000000
  ALL_DAYS  = (SUNDAY + MONDAY + TUESDAY + WEDNESDAY + THURSDAY + FRIDAY + SATURDAY)

  ## Validations ##
  def end_after_start
    if endDate < startDate
      errors.add_to_base("End date cannot preceed start date")
    end
  end

  def daysOfWeek_valid
    daysOfWeek == daysOfWeek & (SUNDAY + MONDAY + TUESDAY + WEDNESDAY + THURSDAY + FRIDAY + SATURDAY)
  end
  ## End Validations ##

  # TODO Is this OperatingTime applicable at +time+
  def valid_at(time=Time.now)
    raise NotImplementedError
  end

  # Tag Helpers
  %w{tag_list tags tag_counts tag_ids tag_tagging_ids tag_taggings}.each do |m| [m,m+"="].each do |m|
    if self.instance_methods.include?("operating_time_"+m)
      self.class_eval "alias #{m.to_sym} #{"operating_time_#{m}".to_sym}"
    end
  end ; end
  def tags_from ; operating_time_tags_from ; end


  def override
    read_attribute(:override) == 1
  end
  def override=(mode)
    if mode == true or mode == "true" or mode == 1
      write_attribute(:override, true)
    elsif mode == false or mode == "false" or mode == 0
      write_attribute(:override, false)
    else
      raise ArgumentError, "Invalid override value (#{mode.inspect}); Accepts true/false, 1/0"
    end
  end

  def daysOfWeek=(newDow)
    if not ( newDow & ALL_DAYS == newDow )
      # Invalid input
      raise ArgumentError, "Not a valid value for daysOfWeek (#{newDow.inspect})"
    end

    write_attribute(:daysOfWeek, newDow & ALL_DAYS)
    @daysOfWeekHash = nil
    @daysOfWeekArray = nil
    @daysOfWeekString = nil
  end


  ## daysOfWeek Helper/Accessors ##

  # Hash mapping day of week (Symbol) to valid(true)/invalid(false)
  def daysOfWeekHash
    @daysOfWeekHash ||= {
      :sunday    => (daysOfWeek & SUNDAY    ) > 0,
      :monday    => (daysOfWeek & MONDAY    ) > 0,
      :tuesday   => (daysOfWeek & TUESDAY   ) > 0,
      :wednesday => (daysOfWeek & WEDNESDAY ) > 0,
      :thursday  => (daysOfWeek & THURSDAY  ) > 0,
      :friday    => (daysOfWeek & FRIDAY    ) > 0,
      :saturday  => (daysOfWeek & SATURDAY  ) > 0
    }
  end

  # Array beginning with Sunday of valid(true)/inactive(false) values
  def daysOfWeekArray
    dow = daysOfWeekHash

    @daysOfWeekArray ||= [
      dow[:sunday],
      dow[:monday],
      dow[:tuesday],
      dow[:wednesday],
      dow[:thursday],
      dow[:friday],
      dow[:saturday]
    ]
  end

  # Human-readable string of applicable days of week
  def daysOfWeekString
    dow = daysOfWeekHash

    @daysOfWeekString ||= (dow[:sunday]    ? "Su" : "") +
                          (dow[:monday]    ? "M"  : "") +
                          (dow[:tuesday]   ? "Tu" : "") +
                          (dow[:wednesday] ? "W"  : "") +
                          (dow[:thursday]  ? "Th" : "") +
                          (dow[:friday]    ? "F"  : "") +
                          (dow[:saturday]  ? "Sa" : "")
  end

  ## End daysOfWeek Helper/Accessors ##

  # Returns the next full occurrence of these operating time rule.
  # If we are currently within a valid time range, it will look forward for the
  # <em>next</em> opening time
  def next_times(at = Time.now)
    at = at.midnight unless at.respond_to? :offset
    return nil if length == 0
    return nil if at.to_date > endDate # Schedules end at 23:59 of the stored endDate
    at = startDate.midnight if at < startDate # This schedule hasn't started yet, skip to startDate

    # Next occurrence is later today
    # This is the only time the "time" actually matters;
    #  after today, all we care about is the date
    if  daysOfWeekArray[at.wday] and
        start >= at.offset
      open = at.midnight + start
      close = open + length
      return [open,close]
    end

    # We don't care about the time offset anymore, jump to the next midnight
    at = at.midnight + 1.day
    # NOTE This also has the added benefit of preventing an infinite loop
    # from occurring if +at+ gets shifted by 0.days further down.

    # Shift daysOfWeekArray so that +at+ is first element
    dow = daysOfWeekArray[at.wday..-1] + daysOfWeekArray[0..(at.wday-1)]
    # NOTE The above call does something a little quirky:
    # In the event that at.wday = 0, it concatenates the array with itself.
    # Since we are only interested in the first true value, this does not
    # cause a problem, but could probably be cleaned up if done so carefully.

    # Next day of the week this schedule is valid for (relative to current day)
    shift = dow.index(true)
    if shift
      # Skip forward
      at = at + shift.days
    else
      # Give up, there are no more occurrences
      # TODO Test edge case: valid for 1 day/week
      return nil
    end

    # Recurse to rerun the validation routines
    return next_times(at)
  end
  alias :to_times :next_times



  def to_xml(options)
    #super(params.merge({:only => [:id, :place_id], :methods => [ {:times => :next_times}, :start, :length, :startDate, :endDate ]}))
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!("operating-time".to_sym) do

      xml.id(self.id)
      xml.place_id(self.place_id)
      #xml.place_name(self.place.name)
      #xml.place_location(self.place.location)
      #xml.place_phone(self.place.phone)
      xml.details(self.details)
      xml.tags do |xml|
        self.tag_list.each do |tag|
          xml.tag(tag)
        end
      end

      xml.start(self.start)
      xml.length(self.length)
      xml.daysOfWeek(self.daysOfWeek)
      xml.startDate(self.startDate)
      xml.endDate(self.endDate)
      xml.override(self.override)

      open,close = self.next_times(Date.today)
      if open.nil? or close.nil?
        xml.next_times(:for => Date.today)
      else
        xml.next_times(:for => Date.today) do |xml|
          xml.open(open.xmlschema)
          xml.close(close.xmlschema)
        end
      end

    end
  end





##### TODO DEPRECATED METHODS #####

  def at
    @at
  end
  def at=(time)
    @opensAt = nil
    @closesAt = nil
    @at = time
  end

  # Returns a Time object representing the beginning of this OperatingTime
  def opensAt
    @opensAt ||= relativeTime.openTime(at)
  end
  def closesAt
    @closesAt ||= relativeTime.closeTime(at)
  end

  # Sets the beginning of this OperatingTime
  # Input: params = { :hour => 12, :minute => 45 }
  def opensAt=(time)
    if time.class == Time
      @opensAt = relativeTime.openTime = time
    else
      super
    end
  end

  # Sets the end of this OperatingTime
  def closesAt=(time)
    @closesAt = relativeTime.closeTime = time
  end


  def start
    read_attribute(:opensAt)
  end

  def start=(offset)
    write_attribute(:opensAt,offset)
  end

  # Returns a RelativeTime object representing this OperatingTime
  def relativeTime
    @relativeTime ||= RelativeTime.new(self, :opensAt, :length)
  end; protected :relativeTime

  # Backwards compatibility with old database schema
  # TODO GET RID OF THIS!!!
  def flags
    ( (override ? 1 : 0) << 7) | read_attribute(:daysOfWeek)
  end

  # FIXME Deprecated, use +override+ instead
  def special
    override
  end
  # Input: isSpecial = true/false
  # FIXME Deprecated, use +override=+ instead
  def special=(isSpecial)
    if isSpecial == true or isSpecial == "true" or isSpecial == 1
      self.override = true
    elsif isSpecial == false or isSpecial == "false" or isSpecial == 0
      self.override = false
    end
  end


end
