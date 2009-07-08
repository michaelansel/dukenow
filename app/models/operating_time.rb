class OperatingTime < ActiveRecord::Base
  belongs_to :place
  acts_as_taggable_on :operating_time_tags
  validates_presence_of :place_id, :endDate, :startDate
  validates_associated :place
  validate :end_after_start, :days_of_week_valid
  validate {|ot| 0 <= ot.length and ot.length <= 1.days }

  ## DaysOfWeek Constants ##
  SUNDAY    = 0b00000001
  MONDAY    = 0b00000010
  TUESDAY   = 0b00000100
  WEDNESDAY = 0b00001000
  THURSDAY  = 0b00010000
  FRIDAY    = 0b00100000
  SATURDAY  = 0b01000000
  ALL_DAYS  = (SUNDAY + MONDAY + TUESDAY + WEDNESDAY + THURSDAY + FRIDAY + SATURDAY)

  ## Validations ##
  def end_after_start
    if endDate < startDate
      errors.add_to_base("End date cannot preceed start date")
    end
  end

  def days_of_week_valid
    days_of_week == days_of_week & (SUNDAY + MONDAY + TUESDAY + WEDNESDAY + THURSDAY + FRIDAY + SATURDAY)
  end
  ## End Validations ##

  # TODO Is this OperatingTime applicable at +time+
  def valid_at(time=Time.now)
    raise NotImplementedError
  end

  # Tag Helpers
  %w{tag_list tags tag_counts tag_ids tag_tagging_ids tag_taggings}.each do |m| [m,m+"="].each do |m|
    if self.instance_methods.include?("operating_time_"+m)
      self.class_eval "alias #{m.to_sym} #{"operating_time_#{m}".to_sym}"
    end
  end ; end
  def tags_from ; operating_time_tags_from ; end


  def override
    read_attribute(:override) == 1
  end
  def override=(mode)
    if mode == true or mode == "true" or mode == 1
      write_attribute(:override, true)
    elsif mode == false or mode == "false" or mode == 0
      write_attribute(:override, false)
    else
      raise ArgumentError, "Invalid override value (#{mode.inspect}); Accepts true/false, 1/0"
    end
  end

  def days_of_week=(newDow)
    if not ( newDow & ALL_DAYS == newDow )
      # Invalid input
      raise ArgumentError, "Not a valid value for days_of_week (#{newDow.inspect})"
    end

    write_attribute(:days_of_week, newDow & ALL_DAYS)
    @days_of_weekHash = nil
    @days_of_weekArray = nil
    @days_of_weekString = nil
  end


  ## days_of_week Helpers ##

  # Hash mapping day of week (Symbol) to valid(true)/invalid(false)
  def days_of_week_hash
    @days_of_week_hash ||= {
      :sunday    => (days_of_week & SUNDAY    ) > 0,
      :monday    => (days_of_week & MONDAY    ) > 0,
      :tuesday   => (days_of_week & TUESDAY   ) > 0,
      :wednesday => (days_of_week & WEDNESDAY ) > 0,
      :thursday  => (days_of_week & THURSDAY  ) > 0,
      :friday    => (days_of_week & FRIDAY    ) > 0,
      :saturday  => (days_of_week & SATURDAY  ) > 0
    }
  end

  # Array beginning with Sunday of valid(true)/inactive(false) values
  def days_of_week_array
    dow = days_of_week_hash

    @days_of_week_array ||= [
      dow[:sunday],
      dow[:monday],
      dow[:tuesday],
      dow[:wednesday],
      dow[:thursday],
      dow[:friday],
      dow[:saturday]
    ]
  end

  # Human-readable string of applicable days of week
  def days_of_week_string
    dow = days_of_week_hash

    @days_of_week_string ||=
                            (dow[:sunday]    ? "Su" : "") +
                            (dow[:monday]    ? "M"  : "") +
                            (dow[:tuesday]   ? "Tu" : "") +
                            (dow[:wednesday] ? "W"  : "") +
                            (dow[:thursday]  ? "Th" : "") +
                            (dow[:friday]    ? "F"  : "") +
                            (dow[:saturday]  ? "Sa" : "")
  end

  ## End days_of_week Helpers ##

  # Returns the next full occurrence of these operating time rule.
  # If we are currently within a valid time range, it will look forward for the
  # <em>next</em> opening time
  def next_times(at = Time.now)
    at = at.midnight unless at.respond_to? :offset
    return nil if length == 0
    return nil if at.to_date > endDate # Schedules end at 23:59 of the stored endDate
    at = startDate.midnight if at < startDate # This schedule hasn't started yet, skip to startDate

    # Next occurrence is later today
    # This is the only time the "time" actually matters;
    #  after today, all we care about is the date
    if  days_of_week_array[at.wday] and
        start >= at.offset
      open = at.midnight + start
      close = open + length
      return [open,close]
    end

    # We don't care about the time offset anymore, jump to the next midnight
    at = at.midnight + 1.day
    # NOTE This also has the added benefit of preventing an infinite loop
    # from occurring if +at+ gets shifted by 0.days further down.

    # Shift days_of_weekArray so that +at+ is first element
    dow = days_of_week_array[at.wday..-1] + days_of_week_array[0..(at.wday-1)]
    # NOTE The above call does something a little quirky:
    # In the event that at.wday = 0, it concatenates the array with itself.
    # Since we are only interested in the first true value, this does not
    # cause a problem, but could probably be cleaned up if done so carefully.

    # Next day of the week this schedule is valid for (relative to current day)
    shift = dow.index(true)
    if shift
      # Skip forward
      at = at + shift.days
    else
      # Give up, there are no more occurrences
      # TODO Test edge case: valid for 1 day/week
      return nil
    end

    # Recurse to rerun the validation routines
    return next_times(at)
  end
  alias :to_times :next_times



  def to_xml(options = {})
    #super(params.merge({:only => [:id, :place_id], :methods => [ {:times => :next_times}, :start, :length, :startDate, :endDate ]}))
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    options[:skip_instruct] = true
    xml.tag!(self.class.to_s.underscore.dasherize) do

      xml.id(self.id)
      xml.place_id(self.place_id)
      #xml.place_name(self.place.name)
      #xml.place_location(self.place.location)
      #xml.place_phone(self.place.phone)
      xml.details(self.details)
      xml.tags do |xml|
        self.tag_list.each do |tag|
          xml.tag(tag)
        end
      end

      xml.start(self.start)
      xml.length(self.length)
      self.days_of_week_hash.to_xml(options.merge(:root => :days_of_week))
      xml.startDate(self.startDate)
      xml.endDate(self.endDate)
      xml.override(self.override)

      open,close = self.next_times(Date.today)
      if open.nil? or close.nil?
        xml.tag!(:next_times.to_s.dasherize, :for => Date.today)
      else
        xml.tag!(:next_times.to_s.dasherize, :for => Date.today) do |xml|
          xml.open(open.xmlschema)
          xml.close(close.xmlschema)
        end
      end

    end
  end





##### TODO DEPRECATED METHODS #####

  # Returns a RelativeTime object representing this OperatingTime
  def relativeTime
    @relativeTime ||= RelativeTime.new(self, :opensAt, :length)
  end; protected :relativeTime

  # Backwards compatibility with old database schema
  # TODO GET RID OF THIS!!!
  def flags
    ( (override ? 1 : 0) << 7) | read_attribute(:days_of_week)
  end

  # FIXME Deprecated, use +override+ instead
  def special
    override
  end
  # Input: isSpecial = true/false
  # FIXME Deprecated, use +override=+ instead
  def special=(isSpecial)
    if isSpecial == true or isSpecial == "true" or isSpecial == 1
      self.override = true
    elsif isSpecial == false or isSpecial == "false" or isSpecial == 0
      self.override = false
    end
  end


end
