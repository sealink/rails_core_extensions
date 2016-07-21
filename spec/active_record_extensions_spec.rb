require 'spec_helper'

describe "optional_fields" do
  let(:model_class) {
    Class.new(ActiveRecord::Base) do
      optional_fields :name, :age, -> { [:age] }
    end
  }

  before do
    stub_const 'Model', model_class
  end

  it 'should know what fields are optional' do
    expect(Model).to be_age_enabled
    expect(Model).to_not be_name_enabled
  end

  it 'should be able to change optional fields' do
    Model.enabled_fields = [:age, :name]
    expect(Model).to be_name_enabled
  end
end

describe 'enum_int' do
  let(:model_class) {
    Class.new(ActiveRecord::Base) do
      enum_int :category_id, %w(one two thr)
    end
  }
  before do
    connect_to_sqlite
    stub_const 'Model', model_class
  end
  let(:one) { Model.new(category_id: 'one') }

  it 'should define constants' do
    expect(Model::CATEGORY_ID_OPTIONS).to eq %w(one two thr)
    expect(Model::CATEGORY_ID_ONE).to eq 0
    expect(Model::CATEGORY_ID_TWO).to eq 1
    expect(Model::CATEGORY_ID_THR).to eq 2
  end

  it 'should define methods' do
    expect(one.category_id_one?).to be true
    expect(one.category_id_two?).to be false
    expect(one.category_id_thr?).to be false
  end

  it 'should define select options' do
    expect(Model::CATEGORY_ID_SELECT_OPTIONS).to eq([
      ['One', 0], ['Two', 1], ['Thr', 2]
    ])
  end

  context 'when short name' do
    let(:model_class) {
      Class.new(ActiveRecord::Base) do
        enum_int :category_id, %w(one two thr), short_name: true
      end
    }

    it 'should define methods' do
      expect(one.one?).to be true
      expect(one.two?).to be false
      expect(one.thr?).to be false
    end
  end
end

describe "ActiveRecord::Base" do
  let(:mock_model) { double }
  let(:model_class) { Class.new(ActiveRecord::Base) }
  before { stub_const 'Model', model_class }

  it "should create a new record if new_or_update! is passed a hash without an :id" do
    attributes = {:fake_column => 'nothing really'}
    expect(Model).to receive(:new).with(attributes)
    Model.new_or_update!(attributes)
  end

  it "should update record if new_or_update! is passed hash with :id" do
    attributes = {:fake_column => 'nothing really', :id => 1}
    expect(Model).to receive(:find) { mock_model }
    expect(mock_model).to receive(:update_attributes!)
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
    has_many :children, dependent: :destroy
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
    connect_to_sqlite
    new.children.create!
    old.children.create!
  end

  after do
    old.destroy
    new.destroy
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
  let(:model_class) {
    Class.new(ActiveRecord::Base) do
      cache_all_attributes :by => 'name'
    end
  }
  let(:first) { Model.create!(:name => 'First') }
  let(:second) { Model.create!(:name => 'Second') }
  let(:expected) {
    {
      'First' => first.attributes,
      'Second' => second.attributes
    }
  }

  before do
    connect_to_sqlite
    stub_const 'Model', model_class
    allow(Model).to receive(:cache) { ActiveSupport::Cache::MemoryStore.new }
    allow(Model).to receive(:should_cache?) { true }
    [first, second]
  end

  it 'should cache all attributes' do
    # Test underlying generate attributes hash method works
    expect(Model.generate_attributes_hash).to eq expected
    expect(Model.attribute_cache).to eq expected

    # Test after save/destroy it updates
    first.destroy
    expect(Model.attribute_cache).to eq 'Second' => second.attributes
    second.destroy # Clean up after
  end
end
