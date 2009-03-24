class OperatingTime < ActiveRecord::Base
  require RAILS_ROOT + '/lib/relative_times.rb'
  include RelativeTimes::InstanceMethods

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
  end

  def special
    (self.flags & SPECIAL_FLAG) == SPECIAL_FLAG
  end

  def special=(isSpecial)
    if isSpecial == true or isSpecial == "true" or isSpecial == 1
      self.flags = self.flags |  SPECIAL_FLAG
    elsif isSpecial == false or isSpecial == "false" or isSpecial == 0
      self.flags = self.flags & ~SPECIAL_FLAG
    end
  end

  def daysOfWeek
    sum = 0
    7.times do |i|
      sum += ( (flags & ALLDAYS_FLAG) & (1 << i) )
    end

    sum
  end

end
