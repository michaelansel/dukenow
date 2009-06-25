class ResetDatabase < ActiveRecord::Migration
  def self.up
    execute 'DELETE FROM schema_migrations WHERE 1;' rescue Exception
    drop_table :places rescue Exception
    drop_table :eateries rescue Exception
    drop_table :operating_times rescue Exception
    drop_table :regular_operating_times rescue Exception
    drop_table :special_operating_times rescue Exception
    drop_table :tags rescue Exception
    drop_table :taggings rescue Exception
  end

  def self.down
  end
end
