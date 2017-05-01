require 'rails_core_extensions/breadcrumb'

require 'action_view'
require 'action_view/helpers'

describe RailsCoreExtensions::Breadcrumb do
  before do
    class MockView
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::CaptureHelper
      attr_accessor :output_buffer
      include RailsCoreExtensions::Breadcrumb

      attr_reader :params

      def initialize(params)
        @params = params
      end
    end
  end

  after { Object.send(:remove_const, 'MockView') }

  subject { MockView.new(:action => action) }

  let(:objects_path) { '/users' }
  let(:parent) { nil }

  before do
    allow(subject).to receive(:objects_path) { objects_path }
    allow(subject).to receive(:collection_url) { objects_path }

    allow(subject).to receive(:parent) { parent }
    allow(subject).to receive(:parent_object) { parent }

    allow(subject).to receive(:controller) { double(:controller, :show => nil) }
    allow(subject).to receive(:url_for).with(action: :show, controller: 'users', id: 1).and_return('/users/1')
  end

  let(:id) { new_record ? nil : 1 }

  context '#breadcrumbs (* = link)' do
    let(:user_class) { double(:user_class, :table_name => 'users', :model_name => double(:singular_route_key => 'user')) }
    let(:user) { double(:user, :id => id, :to_s => 'Alice', :new_record? => new_record, :class => user_class) }
    context 'for a new record' do
      let(:action) { 'new' }
      let(:new_record) { true }

      it 'should breadcrumb: *Users / New' do
        expect(subject).to receive(:link_to).with('Users', '/users') {
          '<a href="/users">Users</a>'.html_safe }
        result = subject.breadcrumbs(user)
        expect(result).to be_html_safe
        expect(result).to eq(
          %q(<ul class="breadcrumb"><li><a href="/users">Users</a></li><li class="active">New</li></ul>)
        )
      end
    end

    context 'for a existing record' do
      let(:new_record) { false }

      context 'when editing' do
        let(:action) { 'edit' }
        it 'should breadcrumb: *Users / *Alice / Edit' do
          expect(subject).to receive(:link_to).with('Users', '/users') {
            '<a href="/users">Users</a>'.html_safe }
          expect(subject).to receive(:link_to).with('Alice', user) {
            '<a href="/users/1">Alice</a>'.html_safe }
          result = subject.breadcrumbs(user)
          expect(result).to be_html_safe
          expect(result).to eq(
            %q(<ul class="breadcrumb"><li><a href="/users">Users</a></li><li><a href="/users/1">Alice</a></li><li class="active">Edit</li></ul>)
          )
        end
      end

      context 'when showing' do
        let(:action) { 'show' }
        it 'should breadcrumb: *Users / Alice' do
          expect(subject).to receive(:link_to).with('Users', '/users') {
            '<a href="/users">Users</a>'.html_safe }
          result = subject.breadcrumbs(user)
          expect(result).to be_html_safe
          expect(result).to eq(
            %q(<ul class="breadcrumb"><li><a href="/users">Users</a></li><li>Alice</li></ul>)
          )
        end
      end
    end
  end
end
