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
