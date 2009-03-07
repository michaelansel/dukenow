class CreateRegularOperatingTimes < ActiveRecord::Migration
  def self.up
    create_table :regular_operating_times do |t|
      t.references :eatery
      t.time :opensAt
      t.time :closesAt
      t.integer :daysOfWeek

      t.timestamps
    end
  end

  def self.down
    drop_table :regular_operating_times
  end
end
