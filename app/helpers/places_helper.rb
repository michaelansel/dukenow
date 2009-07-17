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

  def time_block_style(begin_time, end_time, opts = {})
    if opts[:date]
      opts[:time_range] ||= (opts[:date].midnight)..(opts[:date].midnight+24.hours)
    else
      opts[:time_range] ||= (begin_time.midnight)..(begin_time.midnight+24.hours)
    end
    opts[:direction]  ||= :horizontal

    min_time = opts[:time_range].first
    max_time = opts[:time_range].last
    length = max_time - min_time

    offset = (begin_time - min_time) * 100.0 / length
    size = (end_time - begin_time) * 100.0 / length

    case opts[:direction]
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
