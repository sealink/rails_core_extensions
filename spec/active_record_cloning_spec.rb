require 'spec_helper'

connect_to_sqlite

describe ActiveRecordCloning do
  let(:attrs) {
    {
      name: 'Bill',
      age: '50',
      position: 6,
      category_id: 1
    }
  }
  subject(:record) { model_class.create!(attrs) }
  let(:model_class) { Class.new(ActiveRecord::Base) { self.table_name = 'models' } }

  before do
    ActiveRecord::Base.send :include, ActiveRecordCloning
    ActiveRecord::Base.send :include, ActiveRecordCloning::InstanceMethods
    stub_const 'Model', model_class
    Model.clones_attributes_reset
  end

  after do
    Model.delete_all
  end

  context 'cloned attributes should clone everything' do
    subject(:clone) { record.clone }
    specify { expect(subject.name).to eq 'Bill' }
    specify { expect(subject.age).to eq '50' }
    specify { expect(subject.position).to eq 6 }
    specify { expect(subject.category_id).to eq 1 }
  end

  context 'when model is standard' do
    context 'clone excluding should exclude' do
      subject(:clone_excluding) {
        record.clone_excluding(:category_id) }
      specify { expect(subject.name).to eq 'Bill' }
      specify { expect(subject.age).to eq '50' }
      specify { expect(subject.position).to eq 6 }
      specify { expect(subject.category_id).to be nil }
    end
  end

  context 'when model excludes attributes by default' do
    before do
      model_class.class_eval do
        clones_attributes_except :category_id
      end
    end

    context 'clone excluding should exclude' do
      subject(:clone_excluding) { record.clone_excluding }
      specify { expect(subject.name).to eq 'Bill' }
      specify { expect(subject.age).to eq '50' }
      specify { expect(subject.position).to eq 6 }
      specify { expect(subject.category_id).to be nil }
    end

    context 'clone excluding should exclude additional arguments' do
      subject(:clone_excluding) { record.clone_excluding(:position)
      }
      specify { expect(subject.name).to eq 'Bill' }
      specify { expect(subject.age).to eq '50' }
      specify { expect(subject.position).to eq nil }
      specify { expect(subject.category_id).to be nil }
    end
  end

  context 'when model includes attributes by default' do
    before do
      model_class.class_eval do
        clones_attributes :name, :age
      end
    end

    context 'clone excluding should exclude' do
      subject(:clone_excluding) { record.clone_excluding }
      specify { expect(subject.name).to eq 'Bill' }
      specify { expect(subject.age).to eq '50' }
      specify { expect(subject.position).to eq nil }
      specify { expect(subject.category_id).to be nil }
    end

    context 'clone excluding should exclude additional arguments' do
      subject(:clone_excluding) { record.clone_excluding(:age)
      }
      specify { expect(subject.name).to eq 'Bill' }
      specify { expect(subject.age).to eq nil }
      specify { expect(subject.position).to eq nil }
      specify { expect(subject.category_id).to be nil }
    end
  end
end
