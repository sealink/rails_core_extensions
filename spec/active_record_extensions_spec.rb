require 'spec_helper'

DB_FILE = 'tmp/test_db'
FileUtils.mkdir_p File.dirname(DB_FILE)
FileUtils.rm_f DB_FILE

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => DB_FILE

load('spec/schema.rb')

describe "ActiveRecord::Base" do
  class Model < ActiveRecord::Base
  end

  before do
    @mock_model = mock("mock model")
  end

  it "should create a new record if new_or_update! is passed a hash without an :id" do
    attributes = {:fake_column => 'nothing really'}
    Model.should_receive(:new).with(attributes)
    Model.new_or_update!(attributes)
  end

  it "should update record if new_or_update! is passed hash with :id" do
    attributes = {:fake_column => 'nothing really', :id => 1}
    Model.should_receive(:find).and_return(@mock_model)
    @mock_model.should_receive(:update_attributes!)
    Model.new_or_update!(attributes)
  end

end

describe RailsCoreExtensions::ActionControllerSortable do
  class NormalController < ActionController::Base
  end

  class SortableController < ActionController::Base
    sortable
  end

  class RemoteBadSortableController < ActionController::Base
    remote_bad_sortable
  end

  it 'should sort' do
    NormalController.new.methods.should_not include(:sort)
    SortableController.new.methods.should include(:sort)
    RemoteBadSortableController.new.methods.should include(:move_higher)
  end
end

describe ActiveRecordExtensions do
  class Model < ActiveRecord::Base
    cache_all_attributes :by => 'name'
  end

  before do
    Model.stub!(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    Model.stub!(:should_cache?).and_return(true)
  end

  it 'should cache all attributes' do
    @first = Model.create!(:name => 'First')
    @second = Model.create!(:name => 'Second')

    expected = {'First' => @first.attributes, 'Second' => @second.attributes}
    Model.generate_attributes_hash.should == expected
    Model.attribute_cache.should == expected
  end
end
