class StartLengthSchema < ActiveRecord::Migration
  def self.up
    OperatingTime.find(:all).each{|ot| ot.write_attribute(:closesAt, ot.read_attribute(:closesAt) - ot.read_attribute(:opensAt)) ; ot.save }
    rename_column('operating_times', 'closesAt', 'length')
  end

  def self.down
    OperatingTime.find(:all).each{|ot| ot.length = ot.length + ot.read_attribute(:opensAt) ; ot.save }
    rename_column('operating_times', 'length', 'closesAt')
  end
end
