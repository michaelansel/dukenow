class RevertDaysOfWeekToDaysOfWeek < ActiveRecord::Migration
  def self.up
    rename_column "operating_times", "daysOfWeek", "days_of_week"
  end

  def self.down
    rename_column "operating_times", "days_of_week", "daysOfWeek"
  end
end
