require 'spec_helper'

connect_to_sqlite

describe "ActiveRecord::Base" do
  class Model < ActiveRecord::Base
  end

  before do
    @mock_model = double("mock model")
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

  it 'should sort' do
    # map(&:to_sym) for ruby 1.8 compatibility
    NormalController.new.methods.map(&:to_sym).should_not include(:sort)
    SortableController.new.methods.map(&:to_sym).should include(:sort)
  end
end

describe ActiveRecordExtensions do
  class Parent < ActiveRecord::Base
    has_many :children
    def transfer_children_from(old_parent)
      transfer_records(Child, [old_parent])
    end
  end
  class Child < ActiveRecord::Base
    belongs_to :parent
  end

  let(:old) { Parent.create! }
  let(:new) { Parent.create! }

  before do
    new.children.create!
    old.children.create!
  end

  it 'should transfer records' do
    new.children.size.should == 1
    old.children.size.should == 1
    new.transfer_children_from(old)
    new.reload.children.size.should == 2
    old.reload.children.size.should == 0
  end
end

describe ActiveRecordExtensions do
  class Model < ActiveRecord::Base
    cache_all_attributes :by => 'name'
  end

  before do
    Model.stub(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    Model.stub(:should_cache?).and_return(true)
  end

  it 'should cache all attributes' do
    @first = Model.create!(:name => 'First')
    @second = Model.create!(:name => 'Second')

    expected = {'First' => @first.attributes, 'Second' => @second.attributes}

    # Test underlying generate attributes hash method works
    Model.generate_attributes_hash.should == expected
    Model.attribute_cache.should == expected

    # Test after save/destroy it updates
    @first.destroy
    Model.attribute_cache.should == {'Second' => @second.attributes}
  end
end
