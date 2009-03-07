class RegularOperatingTime < ActiveRecord::Base
  belongs_to :eatery
  require RAILS_ROOT + '/lib/relative_times.rb'
  include RelativeTimes::InstanceMethods
end
