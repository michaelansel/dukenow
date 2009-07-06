class AddBuildingId < ActiveRecord::Migration
  def self.up
    add_column("places", "building_id", :integer)
  end

  def self.down
    remove_column("places", "building_id")
  end
end
