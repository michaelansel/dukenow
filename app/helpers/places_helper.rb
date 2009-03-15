module PlacesHelper
  def settimes
    @startTime = 0 # hard coded midnight start time for window (for dev/testing only)
    @length = 24.hours - 1 # 12 hour window
    @endTime = @startTime + @length
  end

  def time_block_style(time_block)
    settimes
    open = time_block.opensAt.offset
    close = time_block.closesAt.offset

    left = (open - @startTime) * 100 / @length
    width = (close - open) * 100 / @length

    "left: #{left.to_i.to_s}%; width: #{width.to_i.to_s}%;"
  end

  def time_label_style(hour)
    settimes
    time = hour.hours
    left = (time - @startTime) * 100 / @length

    "left: #{left.to_i.to_s}%;"
  end
end
