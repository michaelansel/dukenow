class Place < ActiveRecord::Base
  has_many :operating_times

  def special_operating_times
    operating_times.collect{|t| t.special ? t : nil }.compact
  end

  def regular_operating_times
    operating_times.collect{|t| t.special ? nil : t }.compact
  end

  def schedule(at = Time.now)
    current_schedule = nil

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

  def open?(at = Time.now)
    a = schedule(at)
    return a ? true : false
  end
end
