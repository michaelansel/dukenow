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
  end

  def self.down
    drop_table :operating_times
  end
end
