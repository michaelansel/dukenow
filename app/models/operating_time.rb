class OperatingTime < ActiveRecord::Base
  belongs_to :place
  validates_presence_of :place_id
  validates_associated :place
  validate :end_after_start, :daysOfWeek_valid

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

  # Return array of times representing the open and close times at a certain occurence
  def to_times(at = Time.now)
    # TODO Verify this is a valid occurrence
    open = at.midnight + start
    close = open + length
    [open,close]
  end

  def to_xml(params)
    super(params.merge({:only => [:id, :place_id, :flags], :methods => [ :opensAt, :closesAt, :startDate, :endDate ]}))
  end


  # Returns the next full occurrence of these operating time rule.
  # If we are currently within a valid time range, it will look forward for the
  # <em>next</em> opening time
  def next_times(at = Time.now)
    return nil if at > endDate # This schedule has ended
    at = startDate.midnight if at < startDate # This schedule hasn't started yet, skip to startDate

    # Next occurrence is later today
    # This is the only time the "time" actually matters;
    #  after today, all we care about is the date
    if  daysOfWeekArray[at.wday] and
        start >= (at - at.midnight)
      return to_times(at)
    end

    # We don't care about the time offset anymore, jump to the next midnight
    at = at.midnight + 1.day

    # TODO Test for Sun, Sat, and one of M-F
    dow = daysOfWeekArray[at.wday..-1] + daysOfWeekArray[0..at.wday]

    # Next day of the week this schedule is valid for
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
