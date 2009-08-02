class DiningExtensionIndexes < ActiveRecord::Migration
  def self.up
    add_index :dining_extensions, :place_id
  end

  def self.down
    remove_index :dining_extensions, :place_id
  end
end
