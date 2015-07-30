require 'spec_helper'

connect_to_sqlite

describe "optional_fields" do
  before(:all) do
    Model = Class.new(ActiveRecord::Base) do
      optional_fields :name, :age, -> { [:age] }
    end
  end
  after (:all) { Object.send(:remove_const, 'Model') }

  it 'should know what fields are optional' do
    expect(Model).to be_age_enabled
    expect(Model).to_not be_name_enabled
  end

  it 'should be able to change optional fields' do
    Model.enabled_fields = [:age, :name]
    expect(Model).to be_name_enabled
  end
end

describe "ActiveRecord::Base" do
  before(:all) { Model = Class.new(ActiveRecord::Base) }
  after (:all) { Object.send(:remove_const, 'Model') }

  before do
    @mock_model = double("mock model")
  end

  it "should create a new record if new_or_update! is passed a hash without an :id" do
    attributes = {:fake_column => 'nothing really'}
    expect(Model).to receive(:new).with(attributes)
    Model.new_or_update!(attributes)
  end

  it "should update record if new_or_update! is passed hash with :id" do
    attributes = {:fake_column => 'nothing really', :id => 1}
    expect(Model).to receive(:find) { @mock_model }
    expect(@mock_model).to receive(:update_attributes!)
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
    expect(NormalController.new.methods.map(&:to_sym)).to_not include(:sort)
    expect(SortableController.new.methods.map(&:to_sym)).to include(:sort)
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
    expect(new.children.size).to eq 1
    expect(old.children.size).to eq 1
    new.transfer_children_from(old)
    expect(new.reload.children.size).to eq 2
    expect(old.reload.children.size).to eq 0
  end
end

describe ActiveRecordExtensions do
  before(:all) do
    Model = Class.new(ActiveRecord::Base) do
      cache_all_attributes :by => 'name'
    end
  end
  after (:all) { Object.send(:remove_const, 'Model') }

  before do
    allow(Model).to receive(:cache) { ActiveSupport::Cache::MemoryStore.new }
    allow(Model).to receive(:should_cache?) { true }
  end

  it 'should cache all attributes' do
    @first = Model.create!(:name => 'First')
    @second = Model.create!(:name => 'Second')

    expected = {'First' => @first.attributes, 'Second' => @second.attributes}

    # Test underlying generate attributes hash method works
    expect(Model.generate_attributes_hash).to eq expected
    expect(Model.attribute_cache).to eq expected

    # Test after save/destroy it updates
    @first.destroy
    expect(Model.attribute_cache).to eq 'Second' => @second.attributes
  end
end
