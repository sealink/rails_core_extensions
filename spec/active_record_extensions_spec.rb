require File.expand_path('../../spec_helper', __FILE__)

describe "ActiveRecord::Base" do
  class ARModel < ActiveRecord::Base; end
  
  before do
    @mock_model = mock("mock model")
  end
  
  it "should create a new record if new_or_update! is passed a hash without an :id" do
    attributes = {:fake_column => 'nothing really'}
    ARModel.should_receive(:new).with(attributes)
    ARModel.new_or_update!(attributes)
  end

  it "should update record if new_or_update! is passed hash with :id" do
    attributes = {:fake_column => 'nothing really', :id => 1}
    ARModel.should_receive(:find).and_return(@mock_model)
    @mock_model.should_receive(:update_attributes!)
    ARModel.new_or_update!(attributes)
  end
  
end


