module RelativeTimes
  module ClassMethods
    require 'time'

    def _relativeTime(offset, baseTime = Time.now)
      offset = 0 if offset.nil?
      #offset = 86399 if offset >= 86400
      Time.local(baseTime.year, baseTime.month, baseTime.day, (offset/3600).to_i, ((offset % 3600)/60).to_i)
    end

    def _getMidnightOffset(time)
      time = Time.now if time.nil?
      time.hour * 3600 + time.min  * 60
    end
  end

  module InstanceMethods
    def opensAt
      @relativeOpensAt = RelativeTime.new(self,:opensAtOffset) if @relativeOpensAt.nil?
      @relativeOpensAt
    end
    def closesAt
      @relativeClosesAt = RelativeTime.new(self,:closesAtOffset) if @relativeClosesAt.nil?
      @relativeClosesAt
    end
  end

  module ControllerMethods
    def operatingTimesFormHandler(operatingTimesParams)
=begin
      params[:regular_operating_time][:opensAtOffset] =
        params[:regular_operating_time].delete('opensAtHour') * 3600 +
        params[:regular_operating_time].delete('opensAtMinute') * 60

      params[:regular_operating_time][:closesAtOffset] =
        params[:regular_operating_time].delete('closesAtHour') * 3600 +
        params[:regular_operating_time].delete('closesAtMinute') * 60
=end

      if operatingTimesParams[:daysOfWeekHash] != nil
        operatingTimesParams[:daysOfWeek] = 0
        operatingTimesParams[:daysOfWeekHash].each do |dayOfWeek|
          operatingTimesParams[:daysOfWeek] += 1 << Date::DAYNAMES.index(dayOfWeek.capitalize)
        end
        operatingTimesParams.delete('daysOfWeekHash')
      end

      return operatingTimesParams
    end
  end
end

class RelativeTime
  include RelativeTimes::ClassMethods

  def initialize(object,attribute)
    @object = object
    @attribute = attribute
  end

  def offset
    @object.send(@attribute)
  end
  def offset=(newOffset)
    @object.send(@attribute,"=",newOffset)
  end


  def time(baseTime = Time.now)
    _relativeTime(offset, baseTime)
  end
  def time=(newTime = Time.now)
    offset = _getMidnightOffset(newTime)
  end


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


  def to_s
    '%02d:%02d' % [hour,minute]
  end
end
