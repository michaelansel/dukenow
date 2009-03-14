class Place < ActiveRecord::Base
  has_many :operating_times

  def special_operating_times
    OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) > 0", id] )
  end

  def regular_operating_times
    OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) == 0", id] )
  end

  def daySchedule(at = Date.today)
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

    schedule.sort{|a,b|a.opensAt.offset <=> b.opensAt.offset}
  end

  def currentSchedule(at = Time.now)
    current_schedule = nil

    daySchedule.each do |optime|
      if  optime.opensAt.time(at)  < at and
          optime.closesAt.time(at) > at
        #RAILS_DEFAULT_LOGGER.debug "Opens At: #{optime.opensAt.time(at).to_s}"
        #RAILS_DEFAULT_LOGGER.debug "Closes At: #{optime.closesAt.time(at).to_s}"
        current_schedule = optime
      end
    end
    
    current_schedule
  end
      
=begin

    self.special_operating_times.each do |optime|
      # If we are in a time period with special operating times
      if  optime.startDate <= at.to_date and
          optime.endDate >= at.to_date
        RAILS_DEFAULT_LOGGER.debug "Special Operating Time Period!"
        RAILS_DEFAULT_LOGGER.debug "Effective from #{optime.startDate.to_s}"
        RAILS_DEFAULT_LOGGER.debug "           to  #{optime.endDate.to_s}"
        current_schedule = false if current_schedule.nil?

        # If the place is open right now according to the special operating hours
        if  optime.opensAt.time(at)  < at and
            optime.closesAt.time(at) > at  and
            (1<<at.wday) & optime.daysOfWeek != 0
          RAILS_DEFAULT_LOGGER.debug "Opens At: #{optime.opensAt.time(at).to_s}"
          RAILS_DEFAULT_LOGGER.debug "Closes At: #{optime.closesAt.time(at).to_s}"
          current_schedule = optime
        end
      end

    end

    # If we aren't within a special operating period
    if current_schedule == nil
      current_schedule = false
    else
      return current_schedule
    end

    self.regular_operating_times.each do |optime|
      RAILS_DEFAULT_LOGGER.debug "Operating Times for #{name}"
      RAILS_DEFAULT_LOGGER.debug "Opens At: #{optime.opensAt.time(at).to_s}"
      RAILS_DEFAULT_LOGGER.debug "Closes At: #{optime.closesAt.time(at).to_s}"
      if  optime.opensAt.time(at)  < at and
          optime.closesAt.time(at) > at  and
          (1<<at.wday) & optime.daysOfWeek != 0
        current_schedule = optime
      end
    end

    return current_schedule
  end
=end

  def open?(at = Time.now)
    a = currentSchedule(at)
    return a ? true : false
  end
end
