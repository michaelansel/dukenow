class OverrideAndDaysOfWeekFlags < ActiveRecord::Migration
  def self.up
    add_column "operating_times", "override", :integer, :null => false, :default => 0
    add_column "operating_times", "days_of_week", :integer, :null => false, :default => 0

    OperatingTime.reset_column_information
    OperatingTime.find(:all).each do |ot|
      ot.write_attribute(:override, ot.read_attribute(:flags) & 128) # 128 == Special Flag
      ot.write_attribute(:days_of_week, ot.read_attribute(:flags) & (1+2+4+8+16+32+64) ) # Sum == Flag for each day of the week
      ot.save
    end

    remove_column("operating_times", "flags")
  end

  def self.down
    add_column("operating_times","flags",:integer, :null => false, :default => 0)

    OperatingTime.reset_column_information
    OperatingTime.find(:all).each do |ot|
      ot.write_attribute(:flags, (ot.read_attribute(:override) << 7) | ot.read_attribute(:days_of_week) )
      ot.save
    end

    remove_column("operating_times", "override")
    remove_column("operating_times", "days_of_week")
  end
end
