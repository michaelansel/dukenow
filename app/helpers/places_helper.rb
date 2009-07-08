module PlacesHelper
  # TODO: clean and remove
  def settimes
    length
  end
  def startTime
    @startTime ||= Date.today.midnight
  end
  def endTime
    @endTime ||= (Date.today + 1).midnight
  end
  def length
    @length ||= endTime - startTime
  end

  def time_block_style(time_block_or_start_offset,end_offset = nil, opts = {})
    # Accept "time_block_style(time_block,:direction => :vertical)"
    if end_offset.class == Hash and opts == {}
      opts = end_offset 
      end_offset = nil
    end

    direction = :vertical   if opts[:direction] == :vertical
    direction = :horizontal if opts[:direction] == :horizontal
    direction ||= :horizontal

    if opts[:day] != nil
      @startTime = opts[:day].midnight
      @endTime = startTime + 1.days
    end
    settimes

    if end_offset.nil?

      if time_block_or_start_offset.class == OperatingTime
        # Generate style for OperatingTime object
        open = time_block_or_start_offset.opensAt
        close = time_block_or_start_offset.closesAt

      else
        return time_label_style(time_block_or_start_offset)
      end

    else
      # Generate style for block spanning given time range
      open = startTime.midnight + time_block_or_start_offset
      close = startTime.midnight + end_offset
    end

    if open >= startTime and close <= endTime
      offset = (open - startTime) * 100.0 / length
      size = (close - open) * 100.0 / length

    elsif open >= startTime and close >= endTime
      offset = (open - startTime) * 100.0 / length
      size = (endTime - open) * 100.0 / length
    end

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
      when Date
        time = at.midnight
      when Time,DateTime
        time = at.hour.hours + at.min.minutes
      when Integer,Fixnum,Float
        time = at.to_i.hours
    end
        
    left = (time - startTime) * 100.0 / length

    "left: #{left.to_s}%;"
  end

  # TODO: clean and remove
  def vertical_now_indicator(at=Time.now)
    settimes
    offset = 48; # offset to beginning of dayGraph == width of data cells

    start = (at.hour.hours + at.min.minutes) * 100.0 / length
    start = (100.0 - offset) * start/100.0 + offset # incorporate offset
    "<div class=\"verticalNowIndicator\" style=\"left:#{start.to_s}%;\"></div>"
  end

  # TODO: clean and remove
  def now_indicator(at=Time.now, opts={})
    settimes

    start = (at.hour.hours + at.min.minutes) * 100.0 / length
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
      time.strftime('%I%p').sub(/^0+/,'')
    else # time has minutes
      time.strftime('%I:%M%p').sub(/^0+/,'')
    end
  end


  # Returns [words,time] -- both are strings
  def next_time(place, at=Time.now)
    place.daySchedule(at).each do |open,close|
      # If the whole time period has already passed
      next if close < at

      if open <= at # Open now
        # TODO: Handle late-night rollovers
        return ["Open until", short_time_string(close)]
      end

      if close >= at # Closed now
        return ["Opens at", short_time_string(open)]
      end

      return "ERROR in next_time" # TODO: How could we possibly get here?
    end

    return "","Closed" # No more state time changes for today
  end

end
