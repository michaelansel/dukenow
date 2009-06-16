class OperatingTime < ActiveRecord::Base
  belongs_to :place
  validates_presence_of :place_id
  validates_associated :place

  # Base flags
  SUNDAY_FLAG     = 0b00000000001
  MONDAY_FLAG     = 0b00000000010
  TUESDAY_FLAG    = 0b00000000100
  WEDNESDAY_FLAG  = 0b00000001000
  THURSDAY_FLAG   = 0b00000010000
  FRIDAY_FLAG     = 0b00000100000
  SATURDAY_FLAG   = 0b00001000000
  SPECIAL_FLAG    = 0b00010000000
  DINE_IN_FLAG    = 0b00100000000
  DELIVERY_FLAG   = 0b01000000000


  # Combinations
  ALLDAYS_FLAG    = 0b00001111111
  WEEKDAYS_FLAG   = 0b00000111110
  WEEKENDS_FLAG   = 0b00001000001
  ALL_FLAGS       = 0b01111111111

  def initialize(params = nil)
    super

    # Default values
    self.flags = 0 unless self.flags
    self.startDate = Time.now unless self.startDate
    self.endDate   = Time.now unless self.endDate
    @at = Time.now
  end

  def length
    closesAt - opensAt
  end


  def at
    @at ||= Time.now
  end
  def at=(time)
    @at = time
  end


  def special
    (self.flags & SPECIAL_FLAG) == SPECIAL_FLAG
  end
  # Input: isSpecial = true/false
  def special=(isSpecial)
    if isSpecial == true or isSpecial == "true" or isSpecial == 1
      self.flags = self.flags |  SPECIAL_FLAG
    elsif isSpecial == false or isSpecial == "false" or isSpecial == 0
      self.flags = self.flags & ~SPECIAL_FLAG
    end
  end


  # Returns a Time object representing the beginning of this OperatingTime
  def opensAt
    relativeOpensAt.time(at)
  end
  # Returns a RelativeTime object representing the beginning of this OperatingTime
  def relativeOpensAt
    @relativeOpensAt ||= RelativeTime.new(self,:opensAt) if @relativeOpensAt.nil?
    @relativeOpensAt
  end; protected :relativeOpensAt
  # Sets the beginning of this OperatingTime
  # Input: params = { :hour => 12, :minute => 45 }
  def opensAt=(params = {})
    params[:hour] = 0 if params[:hour].nil?
    params[:minute] = 0 if params[:minute].nil?
    relativeOpensAt.offset = params[:hour].to_i.hours + params[:minute].to_i.minutes
  end


  # Returns a Time object representing the end of this OperatingTime
  def closesAt
    relativeClosesAt.time(at)
  end
  # Returns a RelativeTime object representing the beginning of this OperatingTime
  def relativeClosesAt
    @relativeClosesAt ||= RelativeTime.new(self,:closesAt) if @relativeClosesAt.nil?
    @relativeClosesAt
  end; protected :relativeClosesAt
  # Sets the end of this OperatingTime
  # Input: params = { :hour => 12, :minute => 45 }
  def closesAt=(params = {})
    relativeClosesAt.offset = params[:hour].to_i.hours + params[:minute].to_i.minutes
  end


  # Hash mapping day of week (Symbol) to valid(true)/invalid(false)
  def daysOfWeekHash
    a=daysOfWeek
    daysOfWeek = 127 if a.nil?
    daysOfWeek = a

    { :sunday    => (daysOfWeek &  1) > 0,  # Sunday
      :monday    => (daysOfWeek &  2) > 0,  # Monday
      :tuesday   => (daysOfWeek &  4) > 0,  # Tuesday
      :wednesday => (daysOfWeek &  8) > 0,  # Wednesday
      :thursday  => (daysOfWeek & 16) > 0,  # Thursday
      :friday    => (daysOfWeek & 32) > 0,  # Friday
      :saturday  => (daysOfWeek & 64) > 0}  # Saturday
  end

  # Array beginning with Sunday of valid(true)/inactive(false) values
  def daysOfWeekArray
    a=daysOfWeek
    daysOfWeek = 127 if a.nil?
    daysOfWeek = a

    [ daysOfWeek &  1 > 0,  # Sunday
      daysOfWeek &  2 > 0,  # Monday
      daysOfWeek &  4 > 0,  # Tuesday
      daysOfWeek &  8 > 0,  # Wednesday
      daysOfWeek & 16 > 0,  # Thursday
      daysOfWeek & 32 > 0,  # Friday
      daysOfWeek & 64 > 0]  # Saturday
  end

  # Days of week valid (sum of flags)
  def daysOfWeek
    sum = 0
    7.times do |i|
      sum += ( (flags & ALLDAYS_FLAG) & (1 << i) )
    end

    sum
  end

  # Human-readable string of days of week valid
  def daysOfWeekString
    str = ""

    str += "Su" if flags & SUNDAY_FLAG > 0
    str += "M" if flags & MONDAY_FLAG > 0
    str += "Tu" if flags & TUESDAY_FLAG > 0
    str += "W" if flags & WEDNESDAY_FLAG > 0
    str += "Th" if flags & THURSDAY_FLAG > 0
    str += "F" if flags & FRIDAY_FLAG > 0
    str += "Sa" if flags & SATURDAY_FLAG > 0

    str
  end

  def to_xml(params)
    super(params.merge({:only => [:id, :place_id, :flags], :methods => [ :opensAt, :closesAt, :startDate, :endDate ]}))
  end
end
