module PlacesHelper
  # TODO: clean and remove
  def settimes
    @startTime = 0 # hard coded midnight start time for window (for dev/testing only)
    @length = 24.hours - 1 # 24 hour window
    @endTime = @startTime + @length
  end

  def time_block_style(time_block_or_start_offset,end_offset = nil, opts = {})
    settimes

    # Accept "time_block_style(time_block,:direction => :vertical)"
    if end_offset.class == Hash and opts == {}
      opts = end_offset 
      end_offset = nil
    end

    # TODO: There has GOT to be a more DRY way to code this!
    direction = :horizontal
    if opts[:direction]
      case opts[:direction]
        when :vertical
          direction = :vertical
        when :horizontal
          direction = :horizontal
      end
    end

    if end_offset.nil?

      if time_block_or_start_offset.class == OperatingTime
        open = time_block_or_start_offset.opensAt.offset
        close = time_block_or_start_offset.closesAt.offset

      else
        return time_label_style(time_block_or_start_offset)
      end

    else
      open = time_block_or_start_offset
      close = end_offset
    end

    offset = (open - @startTime) * 100.0 / @length
    size = (close - open) * 100.0 / @length

    case direction
      when :horizontal
        "left: #{offset.to_s}%; width: #{size.to_s}%;"
      when :vertical
        "top: #{offset.to_s}%; height: #{size.to_s}%;"
      else
        ""
    end
  end

  # TODO: clean and remove
  def time_label_style(at)
    settimes
    case at
      when Time
        time = at.hour.hours + at.min.minutes
      when Integer,Fixnum,Float
        time = at.to_i.hours
    end
        
    left = (time - @startTime) * 100.0 / @length

    "left: #{left.to_s}%;"
  end

  # TODO: clean and remove
  def vertical_now_indicator(at=Time.now)
    settimes
    offset = 48; # offset to beginning of dayGraph == width of data cells

    start = (at.hour.hours + at.min.minutes) * 100.0 / @length
    start = (100.0 - offset) * start/100.0 + offset # incorporate offset
    "<div class=\"verticalNowIndicator\" style=\"left:#{start.to_s}%;\"></div>"
  end

  # TODO: clean and remove
  def now_indicator(at=Time.now, opts={})
    settimes

    start = (at.hour.hours + at.min.minutes) * 100.0 / @length
    "<div class=\"nowIndicator\" style=\"top:#{start.to_s}%;\"></div>"
  end

  def placeClasses(place)
    classes = ["place"]

    if place.open?
      classes << "open"
    else
      classes << "closed"
    end

    classes += place.tag_list.split(/,/)

    classes.join(' ')
  end
  
  def short_time_string(time)
    if time.min == 0 # time has no minutes
      time.strftime('%I%p')
    else # time has minutes
      time.strftime('%I:%M%p')
    end
  end


  # Returns [words,time] -- both are strings
  def next_time(place, at=Time.now)
    place.daySchedule.each do |schedule|
      # If the whole time period has already passed
      next if schedule.opensAt.time(at) < at and
              schedule.closesAt.time(at) < at

      if schedule.opensAt.time(at) <= at # Open now
        # TODO: Handle late-night rollovers
        time_string = short_time_string(schedule.closesAt.time(at))
        time_string = time_string.sub(/^0+/,'')
        return ["Open until", time_string]
      end

      if schedule.closesAt.time(at) >= at # Closed now
        time_string = short_time_string(schedule.opensAt.time(at))
        time_string = time_string.sub(/^0+/,'')
        return ["Opens at", time_string]
      end

      return "ERROR in next_time" # TODO: How could we possibly get here?
    end

    return "","Closed" # No more state time changes for today
  end

end
