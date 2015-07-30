require 'spec_helper'

require 'rails_core_extensions/sortable'

connect_to_sqlite

describe RailsCoreExtensions::Sortable do
  before(:all) do
    Model = Class.new(ActiveRecord::Base) do
      default_scope -> { order(:name) }
    end
    @one = Model.create!(name: 'One', position: 1, category_id: 1)
    @two = Model.create!(name: 'Two', position: 2, category_id: 1)
    @thr = Model.create!(name: 'Thr', position: 3, category_id: 2)
  end
  after (:all) do
    Model.delete_all
    Object.send(:remove_const, 'Model')
  end

  let(:params) { { model_body: [@one.id, @thr.id, @two.id] } }
  subject { RailsCoreExtensions::Sortable.new(params, 'models') }

  describe 'when unscoped' do
    let(:scope) { Model.reorder(:position) }
    specify { expect(scope.pluck(:name)).to eq %w(One Two Thr) }
    it 'should correctly sort' do
      subject.sort
      expect(scope.pluck(:name)).to eq %w(One Thr Two)
    end
  end

  describe 'when scoped' do
    let(:scope) { Model.where(category_id: 1).reorder(:position) }
    specify { expect(scope.pluck(:name)).to eq %w(One Two) }

    let(:params) { { category_id: 1, scope: :category_id, model_1_body: [@two.id, @one.id] } }
    it 'should correctly sort' do
      subject.sort
      expect(scope.pluck(:name)).to eq %w(Two One)
    end

    describe 'when params scoped differently' do
      let(:params) { { category_id: 1, scope: :category_id, category_1_body: [@two.id, @one.id] } }
      it 'should correctly sort' do
        subject.sort
        expect(scope.pluck(:name)).to eq %w(Two One)
      end
    end
  end
end
