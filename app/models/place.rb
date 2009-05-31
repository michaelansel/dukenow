class Place < ActiveRecord::Base
  has_many :operating_times
  acts_as_taggable_on :tags

  def special_operating_times
    OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) > 0", id] )
  end

  def regular_operating_times
    OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) == 0", id] )
  end

  def window_schedule(startAt,endAt)
    #TODO Returns the schedule for a specified time window
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

  def open?(at = Time.now)
    a = currentSchedule(at)
    return a ? true : false
  end

  # Alias for <tt>open?</tt>
  def open(at = Time.now); open? at ; end

  def to_xml(params)
    super(params.merge({:only => [:id, :name, :location, :phone], :methods => [ :open ]}))
  end
end
