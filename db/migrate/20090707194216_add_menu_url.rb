class AddMenuUrl < ActiveRecord::Migration
  def self.up
    add_column("dining_extensions", "menu_url", :string)
  end

  def self.down
    remove_column("dining_extensions", "menu_url")
  end
end
