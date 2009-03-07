module RelativeTimes
  module ClassMethods
    require 'time'

    def _relativeTime(offset, baseTime = Time.now)
      Time.local(baseTime.year, baseTime.month, baseTime.day) + offset
    end

    def _getMidnightOffset(time)
      time.hour * 3600 + time.min  * 60 + time.sec 
    end
  end

  module InstanceMethods
    include RelativeTimes::ClassMethods

    def opensAt(baseTime = Time.now)
      offset = read_attribute(:opensAt)
      _relativeTime(offset == nil ? 0 : offset, baseTime)
    end
    def opensAt=(opensAtDateTime = Time.now)
      write_attribute(:opensAt, _getMidnightOffset(opensAtDateTime))
    end

    def closesAt(baseTime = Time.now)
      offset = read_attribute(:closesAt)
      _relativeTime(offset == nil ? 0 : offset, baseTime)
    end
    def closesAt=(closesAtDateTime = Time.now)
      write_attribute(:closesAt, _getMidnightOffset(closesAtDateTime))
    end

  end
end
