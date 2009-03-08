class SpecialOperatingTime < ActiveRecord::Base
  belongs_to :eatery
  require RAILS_ROOT + '/lib/relative_times.rb'
  include RelativeTimes::InstanceMethods

  def opensAtOffset
    read_attribute(:opensAt)
  end
  def closesAtOffset
    read_attribute(:closesAt)
  end

  def daysOfWeek=(newdow)
    RAILS_DEFAULT_LOGGER.debug "Writing new daysOfWeek == #{newdow} ; old == #{daysOfWeek}"
    write_attribute(:daysOfWeek,newdow)
  end

  def daysOfWeekHash

    # Quick hack to work around a possible memory corruption issue
    a=daysOfWeek
    a=127 if a.nil?
    daysOfWeek=a

    # Very weird variable corruption issue????
=begin
    RAILS_DEFAULT_LOGGER.debug "1daysOfWeek == #{daysOfWeek}"
    a = daysOfWeek
    RAILS_DEFAULT_LOGGER.debug "2daysOfWeek == #{daysOfWeek}"
    if a.nil? then
      RAILS_DEFAULT_LOGGER.debug "daysOfWeek is nil; Setting to 127 (all days selected)"
    end
    RAILS_DEFAULT_LOGGER.debug "3daysOfWeek == #{daysOfWeek}"
    RAILS_DEFAULT_LOGGER.debug "AdaysOfWeek == #{a}"

    RAILS_DEFAULT_LOGGER.debug "1old daysOfWeek == #{daysOfWeek}" if daysOfWeek.nil?
    RAILS_DEFAULT_LOGGER.debug "2old daysOfWeek == #{daysOfWeek}" if a.nil?

    daysOfWeek = a
    RAILS_DEFAULT_LOGGER.debug "9daysOfWeek == #{daysOfWeek}" # valid

    a = 10 if false
    RAILS_DEFAULT_LOGGER.debug "0a          == #{a}" # valid
    daysOfWeek = 10 if false
    RAILS_DEFAULT_LOGGER.debug "6daysOfWeek == #{daysOfWeek}" # this shows up nil!

    daysOfWeek = 112 if daysOfWeek.nil?
    RAILS_DEFAULT_LOGGER.debug "7daysOfWeek == #{daysOfWeek}"
    daysOfWeek = 10 if daysOfWeek.nil?
    RAILS_DEFAULT_LOGGER.debug "8daysOfWeek == #{daysOfWeek}"

    RAILS_DEFAULT_LOGGER.debug "1new daysOfWeek == #{daysOfWeek}" if daysOfWeek.nil?
    RAILS_DEFAULT_LOGGER.debug "2new daysOfWeek == #{daysOfWeek}" if a.nil?

    RAILS_DEFAULT_LOGGER.debug "4daysOfWeek == #{daysOfWeek}"

    daysOfWeek = 127 if daysOfWeek.nil?

    RAILS_DEFAULT_LOGGER.debug "5daysOfWeek == #{daysOfWeek}"
    RAILS_DEFAULT_LOGGER.debug ""
=end

    { :sunday    => (daysOfWeek &  1) > 0,  # Sunday
      :monday    => (daysOfWeek &  2) > 0,  # Monday
      :tuesday   => (daysOfWeek &  4) > 0,  # Tuesday
      :wednesday => (daysOfWeek &  8) > 0,  # Wednesday
      :thursday  => (daysOfWeek & 16) > 0,  # Thursday
      :friday    => (daysOfWeek & 32) > 0,  # Friday
      :saturday  => (daysOfWeek & 64) > 0}  # Saturday
  end

  def daysOfWeekArray
    # Quick hack to work around a possible memory corruption issue
    a=daysOfWeek
    a=127 if a.nil?
    daysOfWeek=a
    ##################


    [ daysOfWeek &  1 > 0,  # Sunday
      daysOfWeek &  2 > 0,  # Monday
      daysOfWeek &  4 > 0,  # Tuesday
      daysOfWeek &  8 > 0,  # Wednesday
      daysOfWeek & 16 > 0,  # Thursday
      daysOfWeek & 32 > 0,  # Friday
      daysOfWeek & 64 > 0]  # Saturday
  end
end
