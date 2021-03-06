require 'spec_helper'

require 'rails_core_extensions/sortable'

describe RailsCoreExtensions::Sortable do
  let(:model_class) {
    Class.new(ActiveRecord::Base) do
      default_scope -> { order(:name) }
    end
  }

  before do
    connect_to_sqlite

    stub_const 'Model', model_class

    models
  end

  let(:one) { Model.create!(name: 'One', position: 1, category_id: 1) }
  let(:two) { Model.create!(name: 'Two', position: 2, category_id: 1) }
  let(:thr) { Model.create!(name: 'Thr', position: 3, category_id: 2) }
  let(:models) { [one, two, thr] }

  after do
    models.each(&:destroy)
  end

  subject { RailsCoreExtensions::Sortable.new(ActionController::Parameters.new(params), 'models') }

  RSpec.shared_examples 'unscoped' do
    let(:scope) { Model.reorder(:position) }
    specify { expect(scope.pluck(:name)).to eq %w(One Two Thr) }
    it 'should correctly sort' do
      subject.sort
      expect(scope.pluck(:name)).to eq %w(One Thr Two)
    end
  end

  describe 'when unscoped due to blank scope' do
    let(:params) { { model_body: [one.id, thr.id, two.id], scope: "" } }
    it_behaves_like 'unscoped'
  end

  describe 'when unscoped due to lack of scope' do
    let(:params) { { model_body: [one.id, thr.id, two.id] } }
    it_behaves_like 'unscoped'
  end

  describe 'when scoped' do
    let(:scope) { Model.where(category_id: 1).reorder(:position) }
    specify { expect(scope.pluck(:name)).to eq %w(One Two) }

    let(:params) { { category_id: 1, scope: :category_id, model_1_body: [two.id, one.id] } }
    it 'should correctly sort' do
      subject.sort
      expect(scope.pluck(:name)).to eq %w(Two One)
    end

    describe 'when params scoped differently' do
      let(:params) { { category_id: 1, scope: :category_id, category_1_body: [two.id, one.id] } }
      it 'should correctly sort' do
        subject.sort
        expect(scope.pluck(:name)).to eq %w(Two One)
      end
    end
  end
end
