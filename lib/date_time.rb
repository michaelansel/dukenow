

module Midnight
  def midnight
    Time.mktime(year, month, day, 0, 0, 0);
  end
end



require 'date'
class Date
  include Midnight
end

require 'time'
class Time
  include Midnight
end

class DateTime
  include Midnight
end
