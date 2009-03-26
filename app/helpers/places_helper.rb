module PlacesHelper
  def settimes
    @startTime = 0 # hard coded midnight start time for window (for dev/testing only)
    @length = 24.hours - 1 # 24 hour window
    @endTime = @startTime + @length
  end

  def time_block_style(time_block_or_start_offset,end_offset = nil)
    settimes
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

    left = (open - @startTime) * 100.0 / @length
    width = (close - open) * 100.0 / @length

    "left: #{left.to_s}%; width: #{width.to_s}%;"
  end

  def vertical_time_block_style(time_block_or_start_offset,end_offset = nil)
    settimes

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
    
    top = (open-@startTime)*100.0/@length
    height = (close-open)*100.0/@length

    "top: #{top.to_s}%;height: #{height.to_s}%;"
  end

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
end
