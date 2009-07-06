class StartLengthSchema < ActiveRecord::Migration
  def self.up
    OperatingTime.find(:all).each do |ot|
      ot.write_attribute(:closesAt, ot.read_attribute(:closesAt) - ot.read_attribute(:opensAt))
      ot.write_attribute(:startDate, ot.read_attribute(:startDate) || Date.new(Date.today.year,1,1))
      ot.write_attribute(:endDate, ot.read_attribute(:endDate) || Date.new(Date.today.year,12,31))
      ot.save_without_validation
    end
    rename_column('operating_times', 'closesAt', 'length')
  end

  def self.down
    OperatingTime.find(:all).each{|ot| ot.length = ot.length + ot.read_attribute(:opensAt) ; ot.save_without_validation }
    rename_column('operating_times', 'length', 'closesAt')
  end
end
