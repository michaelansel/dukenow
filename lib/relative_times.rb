class RelativeTime
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


    require 'time'

    def _relativeTime(offset, baseTime = Time.now)
      Time.local(baseTime.year, baseTime.month, baseTime.day, (offset/3600).to_i, offset % 3600)
    end

    def _getMidnightOffset(time)
      time.hour * 3600 + time.min  * 60
    end
end


module RelativeTimes
  module ClassMethods
    require 'time'

    def _relativeTime(offset, baseTime = Time.now)
      Time.local(baseTime.year, baseTime.month, baseTime.day, (offset/3600).to_i, offset % 3600)
    end

    def _getMidnightOffset(time)
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
    def operatingTimesFormHandler
      params[:regular_operating_time][:opensAtOffset] =
        params[:regular_operating_time].delete('opensAtHour') * 3600 +
        params[:regular_operating_time].delete('opensAtMinute') * 60

      params[:regular_operating_time][:closesAtOffset] =
        params[:regular_operating_time].delete('closesAtHour') * 3600 +
        params[:regular_operating_time].delete('closesAtMinute') * 60

      params[:regular_operating_time][:daysOfWeek] = 0
      params[:regular_operating_time][:daysOfWeekHash].each do |dayOfWeek|
        params[:regular_operating_time][:daysOfWeek] += 1 << Date::DAYNAMES.index(dayOfWeek.capitalize)
      end
      params[:regular_operating_time].delete('daysOfWeekHash')
    end
  end
end
