module PlacesHelper
  def settimes
    @startTime = 0 # hard coded midnight start time for window (for dev/testing only)
    @length = 24.hours - 1 # 24 hour window
    @endTime = @startTime + @length
  end

  def time_block_style(time_block)
    settimes
    open = time_block.opensAt.offset
    close = time_block.closesAt.offset

    left = (open - @startTime) * 100.0 / @length
    width = (close - open) * 100.0 / @length

    "left: #{left.to_s}%; width: #{width.to_s}%;"
  end

  def time_label_style(at)
    settimes
    case at
      when Time
        time = at.hour.hours + at.min.minutes
      when Integer
        time = at.to_i.hours
    end
        
    left = (time - @startTime) * 100.0 / @length

    "left: #{left.to_s}%;"
  end
end
