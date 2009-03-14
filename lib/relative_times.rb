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
      @relativeOpensAt = RelativeTime.new(self,:opensAt) if @relativeOpensAt.nil?
      @relativeOpensAt
    end
    # Input: params = { :hour => 12, :minute => 45 }
    def opensAt=(params = {})
      params[:hour] = 0 if params[:hour].nil?
      params[:minute] = 0 if params[:minute].nil?
      opensAt.offset = params[:hour].to_i.hours + params[:minute].to_i.minutes
    end
      
      
    def closesAt
      @relativeClosesAt = RelativeTime.new(self,:closesAt) if @relativeClosesAt.nil?
      @relativeClosesAt
    end
    def closesAt=(params = {})
      closesAt.offset = params[:hour].to_i.hours + params[:minute].to_i.minutes
    end



    def daysOfWeekHash
      a=daysOfWeek
      daysOfWeek = 127 if a.nil?
      daysOfWeek = a

      { :sunday    => (daysOfWeek &  1) > 0,  # Sunday
        :monday    => (daysOfWeek &  2) > 0,  # Monday
        :tuesday   => (daysOfWeek &  4) > 0,  # Tuesday
        :wednesday => (daysOfWeek &  8) > 0,  # Wednesday
        :thursday  => (daysOfWeek & 16) > 0,  # Thursday
        :friday    => (daysOfWeek & 32) > 0,  # Friday
        :saturday  => (daysOfWeek & 64) > 0}  # Saturday
    end

    def daysOfWeekArray
      a=daysOfWeek
      daysOfWeek = 127 if a.nil?
      daysOfWeek = a

      [ daysOfWeek &  1 > 0,  # Sunday
        daysOfWeek &  2 > 0,  # Monday
        daysOfWeek &  4 > 0,  # Tuesday
        daysOfWeek &  8 > 0,  # Wednesday
        daysOfWeek & 16 > 0,  # Thursday
        daysOfWeek & 32 > 0,  # Friday
        daysOfWeek & 64 > 0]  # Saturday
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
        daysOfWeek = 0

        operatingTimesParams[:daysOfWeekHash].each do |dayOfWeek|
          daysOfWeek += 1 << Date::DAYNAMES.index(dayOfWeek.capitalize)
        end
        operatingTimesParams.delete('daysOfWeekHash')

        operatingTimesParams[:flags] = 0 if operatingTimesParams[:flags].nil?
        operatingTimesParams[:flags] = operatingTimesParams[:flags] & ~OperatingTime::ALLDAYS_FLAG
        operatingTimesParams[:flags] = operatingTimesParams[:flags] |  daysOfWeek
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
    @object.send(:read_attribute,@attribute)
  end
  def offset=(newOffset)
    @object.send(:write_attribute,@attribute,newOffset)
  end


  def time(baseTime = Time.now)
    _relativeTime(offset, baseTime)
  end
  def time=(newTime = Time.now)
    RAILS_DEFAULT_LOGGER.debug "Updating offset using Time object: #{newTime.inspect} ; offset = #{_getMidnightOffset(newTime)}"
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
