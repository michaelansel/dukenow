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
    end
  end


  ## daysOfWeek Helper/Accessors ##

  # Hash mapping day of week (Symbol) to valid(true)/invalid(false)
  def daysOfWeekHash
    { :sunday    => (daysOfWeek & SUNDAY    ) > 0,
      :monday    => (daysOfWeek & MONDAY    ) > 0,
      :tuesday   => (daysOfWeek & TUESDAY   ) > 0,
      :wednesday => (daysOfWeek & WEDNESDAY ) > 0,
      :thursday  => (daysOfWeek & THURSDAY  ) > 0,
      :friday    => (daysOfWeek & FRIDAY    ) > 0,
      :saturday  => (daysOfWeek & SATURDAY  ) > 0}
  end

  # Array beginning with Sunday of valid(true)/inactive(false) values
  def daysOfWeekArray
    dow = daysOfWeekHash

    [ dow[:sunday],
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
    str = ""

    str += "Su" if dow[:sunday]
    str += "M"  if dow[:monday]
    str += "Tu" if dow[:tuesday]
    str += "W"  if dow[:wednesday]
    str += "Th" if dow[:thursday]
    str += "F"  if dow[:friday]
    str += "Sa" if dow[:saturday]

    str
  end

  ## End daysOfWeek Helper/Accessors ##

  # TODO Return array of times representing the open and close times at a certain occurence
  def to_times(at = Time.now)
    raise NotImplementedError
    open = Time.now
    close = Time.now
    [open,close]
  end

  def to_xml(params)
    super(params.merge({:only => [:id, :place_id, :flags], :methods => [ :opensAt, :closesAt, :startDate, :endDate ]}))
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
    @opensAt = relativeTime.openTime = time
  end

  # Sets the end of this OperatingTime
  def closesAt=(time)
    @closesAt = relativeTime.closeTime = time
  end



  def length
    closesAt - opensAt
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
