class OperatingTimeIndexes < ActiveRecord::Migration
  def self.up
    add_index :operating_times, :place_id
    add_index :operating_times, [:startDate, :endDate]
  end

  def self.down
    remove_index :operating_times, :place_id
    remove_index :operating_times, [:startDate, :endDate]
  end
end
