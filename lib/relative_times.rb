module RelativeTimes
  module ClassMethods
    require 'time'

    def _relativeTime(offset, baseTime = Time.now)
      Time.utc(baseTime.year, baseTime.month, baseTime.day) + offset
    end

    def _getMidnightOffset(time)
      RAILS_DEFAULT_LOGGER.error time.inspect
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
