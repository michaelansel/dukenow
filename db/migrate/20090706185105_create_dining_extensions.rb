class CreateDiningExtensions < ActiveRecord::Migration
  def self.up
    create_table :dining_extensions do |t|
      t.integer "place_id"
      t.string  "logo_url"
      t.string  "more_info_url"
      t.string  "owner_operator"
      t.string  "payment_methods"

      t.timestamps
    end
  end

  def self.down
    drop_table :dining_extensions
  end
end
