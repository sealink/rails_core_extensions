require 'spec_helper'

describe RailsCoreExtensions::TransferRecords do
  class Parent < ActiveRecord::Base
    has_many :children, dependent: :destroy
    def transfer_children_from(old_parent)
      RailsCoreExtensions::TransferRecords.new(self, Child).transfer_from([old_parent])
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

