class SpecialOperatingTime < ActiveRecord::Base
  belongs_to :eatery
  require RAILS_ROOT + '/lib/relative_times.rb'
  include RelativeTimes::InstanceMethods

  def daysOfWeekHash
    daysOfWeek = 0 if daysOfWeek.nil?
    { :sunday    => daysOfWeek &  1 > 0,  # Sunday
      :monday    => daysOfWeek &  2 > 0,  # Monday
      :tuesday   => daysOfWeek &  4 > 0,  # Tuesday
      :wednesday => daysOfWeek &  8 > 0,  # Wednesday
      :thursday  => daysOfWeek & 16 > 0,  # Thursday
      :friday    => daysOfWeek & 32 > 0,  # Friday
      :saturday  => daysOfWeek & 64 > 0}  # Saturday
  end

  def daysOfWeekArray
    daysOfWeek = 0 if daysOfWeek.nil?
    [ daysOfWeek &  1 > 0,  # Sunday
      daysOfWeek &  2 > 0,  # Monday
      daysOfWeek &  4 > 0,  # Tuesday
      daysOfWeek &  8 > 0,  # Wednesday
      daysOfWeek & 16 > 0,  # Thursday
      daysOfWeek & 32 > 0,  # Friday
      daysOfWeek & 64 > 0]  # Saturday
  end
end
