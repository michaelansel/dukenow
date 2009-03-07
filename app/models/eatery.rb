class Eatery < ActiveRecord::Base
  has_many :regular_operating_times
  has_many :special_operating_times

  def open?(at = Time.now)
    open = nil
    #TODO Needs to handle special operating hours

    #at_offset = at.hour * 3600 + at.min * 60 + at.sec
    special_operating_times.each do |operating_time|
      #RAILS_DEFAULT_LOGGER.debug "Operating Times for #{name}"
      #RAILS_DEFAULT_LOGGER.debug "Opens At: #{operating_time.opensAt(at).to_s}"
      #RAILS_DEFAULT_LOGGER.debug "Closes At: #{operating_time.closesAt(at).to_s}"

      if  operating_time.start <= at.to_date and
          operating_time.end >= at.to_date
        RAILS_DEFAULT_LOGGER.info "Special Operating Time Period!"
        open = false if open == nil

        if  operating_time.opensAt(at)  < at and
            operating_time.closesAt(at) > at  and
            (1<<at.wday) & operating_time.daysOfWeek != 0 and
          open = true
        end
      end

    end

    if open == nil
      open = false
    else
      return open
    end

    regular_operating_times.each do |operating_time|
      RAILS_DEFAULT_LOGGER.debug "Operating Times for #{name}"
      RAILS_DEFAULT_LOGGER.debug "Opens At: #{operating_time.opensAt(at).to_s}"
      RAILS_DEFAULT_LOGGER.debug "Closes At: #{operating_time.closesAt(at).to_s}"
      if  operating_time.opensAt(at)  < at and
          operating_time.closesAt(at) > at  and
          (1<<at.wday) & operating_time.daysOfWeek != 0
        open = true
      end
    end

    return open
  end
end
