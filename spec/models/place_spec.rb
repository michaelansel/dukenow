require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Place do
  before(:each) do
    @valid_attributes = {
      :name => 'Test Place',
      :location => 'Somewhere',
      :phone => '(919) 555-1212'
    }
  end

  it "should create a new instance given valid attributes" do
    Place.create!(@valid_attributes)
  end

  it "should not create a new instance without a name" do
    @valid_attributes.delete(:name)
    lambda { Place.create!(@valid_attributes) }.should raise_error
  end

  # TODO Create mocks for OperatingTime so we can test the scheduling methods
end
