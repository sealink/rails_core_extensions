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
