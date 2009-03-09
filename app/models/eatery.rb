class Eatery < ActiveRecord::Base
  has_many :regular_operating_times
  has_many :special_operating_times

  def schedule(at = Time.now)
    current_schedule = nil

    special_operating_times.each do |operating_time|
      # If we are in a time period with special operating times
      if  operating_time.start <= at.to_date and
          operating_time.end >= at.to_date
        RAILS_DEFAULT_LOGGER.debug "Special Operating Time Period!"
        RAILS_DEFAULT_LOGGER.debug "Effective from #{operating_time.start.to_s}"
        RAILS_DEFAULT_LOGGER.debug "           to  #{operating_time.end.to_s}"
        current_schedule = false if current_schedule.nil?

        # If the eatery is open right now according to the special operating hours
        if  operating_time.opensAt.time(at)  < at and
            operating_time.closesAt.time(at) > at  and
            (1<<at.wday) & operating_time.daysOfWeek != 0
          RAILS_DEFAULT_LOGGER.debug "Opens At: #{operating_time.opensAt.time(at).to_s}"
          RAILS_DEFAULT_LOGGER.debug "Closes At: #{operating_time.closesAt.time(at).to_s}"
          current_schedule = operating_time
        end
      end

    end

    # If we aren't within a special operating period
    if current_schedule == nil
      current_schedule = false
    else
      return current_schedule
    end

    regular_operating_times.each do |operating_time|
      RAILS_DEFAULT_LOGGER.debug "Operating Times for #{name}"
      RAILS_DEFAULT_LOGGER.debug "Opens At: #{operating_time.opensAt.time(at).to_s}"
      RAILS_DEFAULT_LOGGER.debug "Closes At: #{operating_time.closesAt.time(at).to_s}"
      if  operating_time.opensAt.time(at)  < at and
          operating_time.closesAt.time(at) > at  and
          (1<<at.wday) & operating_time.daysOfWeek != 0
        current_schedule = operating_time
      end
    end

    return current_schedule
  end

  def open?(at = Time.now)
    a = schedule(at)
    return a ? true : false
  end
end
