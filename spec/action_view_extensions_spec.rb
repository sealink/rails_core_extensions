require "rails_core_extensions/action_view_extensions"

require "action_view"

describe RailsCoreExtensions::ActionViewExtensions do
  before do
    class TestModel1
      include ActionView::Helpers::FormTagHelper
      include ActionView::Helpers::FormOptionsHelper
      include RailsCoreExtensions::ActionViewExtensions
    end
  end

  after { Object.send(:remove_const, "TestModel1") }

  let(:helper) { TestModel1.new }

  context "#boolean_select_tag" do
    let(:yes_no) { [%w[Yes 1], %w[No 0]] }
    subject { helper.boolean_select_tag("name", args) }

    context "when elements selected" do
      let(:args) { { selected: 0 } }
      let(:options) { helper.options_for_select(yes_no, selected: "0") }

      it { is_expected.to eq helper.select_tag("name", options) }

      context "and other options passed" do
        let(:args) { { selected: "0", include_blank: "All" } }
        it {
          is_expected.to eq helper.select_tag(
            "name",
            options,
            include_blank: "All",
          )
        }
      end
    end
  end
end
