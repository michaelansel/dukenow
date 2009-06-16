class RelativeTime
  require 'time'

  def self._relativeTime(offset, baseTime = Time.now)
    offset = 0 if offset.nil?
    #offset = 86399 if offset >= 86400
    Time.local(baseTime.year, baseTime.month, baseTime.day, (offset/3600).to_i, ((offset % 3600)/60).to_i)
  end

  def self._getMidnightOffset(time)
    time = Time.now if time.nil?
    time.hour * 3600 + time.min  * 60
  end


  def initialize(object,startAttribute,lengthAttribute)
    @object = object
    @startAttribute = startAttribute
    @lengthAttribute = lengthAttribute
  end


=begin
  def hour
    (offset / 3600).to_i
  end
  def hour=(hour)
    #        hour_seconds  + remainder_seconds
    offset = (hour * 3600) + (offset % 3600)
  end


  def minute
    ( (offset % 3600) / 60 ).to_i
  end
  def minute=(minute)
    #        hour_seconds  + minute_seconds + remainder_seconds
    offset = (hour * 3600) + (minute * 60) + (offset % 60)
  end
=end


  def offset
    @object.send(:read_attribute,@startAttribute)
  end
  def offset=(newOffset)
    @object.send(:write_attribute,@startAttribute,newOffset)
  end

  def length
    @object.send(:read_attribute,@lengthAttribute)
  end
  def length=(newLength)
    @object.send(:write_attribute,@lengthAttribute,newLength)
  end


  def openTime(baseTime = Time.now)
    RelativeTime._relativeTime(offset, baseTime)
  end
  def openTime=(newTime = Time.now)
    RAILS_DEFAULT_LOGGER.debug "Updating offset using Time object: #{newTime.inspect} ; offset = #{RelativeTime._getMidnightOffset(newTime)}"
    offset = RelativeTime._getMidnightOffset(newTime)
  end

  def closeTime(baseTime = Time.now)
    RelativeTime._relativeTime(offset, baseTime) + length
  end
  def closeTime=(newTime = Time.now)
    RAILS_DEFAULT_LOGGER.debug "Updating offset using Time object: #{newTime.inspect} ; offset = #{RelativeTime._getMidnightOffset(newTime)}"
    length = newTime - openTime
    length = length + 24*60*60 if length < 0
  end

  def to_s
    '%02d:%02d' % [hour,minute]
    time.to_s
  end
end
