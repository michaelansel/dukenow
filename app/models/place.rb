class Place < ActiveRecord::Base
  has_many :operating_times
  acts_as_taggable_on :tags

  def special_operating_times
    OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) > 0", id], :order => "startDate ASC, opensAt ASC" )
  end

  def regular_operating_times
    OperatingTime.find( :all, :conditions => ["place_id = ? and (flags & #{OperatingTime::SPECIAL_FLAG}) == 0", id], :order => "startDate ASC, opensAt ASC" )
  end

  # Returns an array of OperatingTimes
  def schedule(startAt,endAt)
    # TODO Returns the schedule for a specified time window
    # TODO Handle events starting within the range but ending outside of it?
    regular_times = regular_operating_times.select do |ot|
      ot.at = startAt
      ot.startDate ||= startAt.to_date
      ot.endDate ||= endAt.to_date
      (ot.startDate <= startAt.to_date and ot.endDate >= endAt.to_date) and
        ((ot.opensAt >= startAt and ot.opensAt <= endAt) or (ot.closesAt >= startAt and ot.closesAt <= endAt))
    end
    special_times = special_operating_times.select do |ot|
      ot.at = startAt
      ot.startDate ||= startAt.to_date
      ot.endDate ||= endAt.to_date
      (ot.startDate <= startAt.to_date and ot.endDate >= endAt.to_date) and
        ((ot.opensAt >= startAt and ot.opensAt <= endAt) or (ot.closesAt >= startAt and ot.closesAt <= endAt))
    end

    # TODO Handle combinations (i.e. part special, part regular)
    special_times == [] ? regular_times : special_times
  end

  def daySchedule(at = Date.today)
    if at.nil?
      instance_eval("class Place::MonkeyButt < StandardError ; end")
      raise MonkeyButt, "Oh no! It looks like we found a monkey butt!"
    end
    at = at.to_date if at.class == Time or at.class == DateTime

    schedule = schedule(at.midnight,(at+1).midnight)
    schedule = schedule.select {|ot| (ot.flags & 1<<at.wday) > 0 }
    schedule.each {|t| t.at = at }

=begin
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

    schedule.sort{|a,b|a.opensAt <=> b.opensAt}
=end
  end

  def currentSchedule(at = Time.now)
    if at.nil?
      instance_eval("class Place::MonkeyButt < StandardError ; end")
      raise MonkeyButt, "Oh no! It looks like we found a monkey butt!"
    end
    current_schedule = nil

    daySchedule(at).each do |optime|
      if optime.opensAt  <= at and
         optime.closesAt >= at
        #RAILS_DEFAULT_LOGGER.debug "Opens At: #{optime.opensAt.time(at).to_s}"
        #RAILS_DEFAULT_LOGGER.debug "Closes At: #{optime.closesAt.time(at).to_s}"
        current_schedule = optime
      end
    end
    
    current_schedule
  end

  def open?(at = Time.now)
    if at.nil?
      instance_eval("class Place::MonkeyButt < StandardError ; end")
      raise MonkeyButt, "Oh no! It looks like we found a monkey butt!"
    end
    a = currentSchedule(at)
    return a ? true : false
  end

  # Alias for <tt>open?</tt>
  def open(at = Time.now); open? at ; end

  def to_json(params)
    super(params.merge({:only => [:id, :name, :location, :phone], :methods => [ :open ]}))
  end
  def to_xml(params)
    super(params.merge({:only => [:id, :name, :location, :phone], :methods => [ :open ]}))
  end
end
