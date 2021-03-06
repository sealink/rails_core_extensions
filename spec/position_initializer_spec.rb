require 'spec_helper'

describe RailsCoreExtensions::PositionInitializer, 'When repositioning' do
  class Child < ActiveRecord::Base; end

  before do
    connect_to_sqlite
    Child.create!(parent_id: 1, name: 'A child')
  end

  after do
    child.destroy
  end

  subject { RailsCoreExtensions::PositionInitializer.new(Child, :parent_id) }
  let(:child) { Child.find_by_name('A child') }

  context 'when not initialized' do
    specify { expect(child.position).to be_nil }
  end

  context 'when positioned' do
    before { subject.positionalize }

    specify { expect(child.position).to eq 1 }

    context 'when additional models are created' do
      let(:child2) { Child.find_by_name('Another child') }
      let(:child3) { Child.find_by_name('Third child')   }

      before do
        Child.create!(parent_id: 2, name: 'Another child')
        Child.create!(parent_id: 1, name: 'Third child')
      end

      after do
        child2.destroy
        child3.destroy
      end

      context 'when re-positioned' do
        before { subject.positionalize }

        it 'should reposition in groups by linked parent' do
          expect(child.position).to eq 2
          expect(child3.position).to eq 1
          expect(child2.position).to eq 1
        end
      end
    end
  end
end
