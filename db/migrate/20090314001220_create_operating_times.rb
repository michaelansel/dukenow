class CreateOperatingTimes < ActiveRecord::Migration
  def self.up
    create_table :operating_times do |t|
      t.references :place
      t.integer :opensAt
      t.integer :closesAt
      t.text :details
      t.integer :flags
      t.date :startDate
      t.date :endDate

      t.timestamps
    end

    #execute "insert into operating_times (place_id, opensAt, closesAt, flags) select eatery_id as place_id,opensAt,closesAt,daysOfWeek as flags from regular_operating_times"
    #execute "insert into operating_times (place_id, opensAt, closesAt, flags, startDate, endDate) select eatery_id as place_id,opensAt,closesAt,daysOfWeek as flags,start as startDate,end as endDate from special_operating_times"
    #execute "update operating_times set flags = (flags + 128) where startDate not null and endDate not null"
  end

  def self.down
    drop_table :operating_times
  end
end
