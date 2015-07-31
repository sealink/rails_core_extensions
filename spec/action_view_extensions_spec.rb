require 'rails_core_extensions/action_view_extensions'

require 'action_view'

describe RailsCoreExtensions::ActionViewExtensions do
  before do
    class TestModel1
      include ActionView::Helpers::FormTagHelper
      include ActionView::Helpers::FormOptionsHelper
      include RailsCoreExtensions::ActionViewExtensions
    end
  end

  after { Object.send(:remove_const, 'TestModel1') }

  subject { TestModel1.new }

  context '#boolean_select_tag' do
    it 'should generate and have selected element selected' do
      expect(subject.boolean_select_tag('name', selected: '0')).to eq(
        subject.select_tag('name', subject.options_for_select([['Yes', '1'], ['No', '0']], selected: '0'))
      )
    end
  end
end
