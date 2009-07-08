class RenameOpensAtToStart < ActiveRecord::Migration
  def self.up
    rename_column("operating_times", "opensAt", "start")
  end

  def self.down
    rename_column("operating_times", "start", "opensAt")
  end
end
