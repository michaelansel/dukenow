class CreateSpecialOperatingTimes < ActiveRecord::Migration
  def self.up
    create_table :special_operating_times do |t|
      t.references :eatery
      t.integer :opensAt
      t.integer :closesAt
      t.integer :daysOfWeek
      t.date :start
      t.date :end

      t.timestamps
    end
  end

  def self.down
    drop_table :special_operating_times
  end
end
