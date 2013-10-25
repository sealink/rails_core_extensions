require 'rails_core_extensions/active_model_extensions'
require 'spec_helper_model_base'

describe ActiveModelExtensions do
  include NullDB::CustomNullifiedDatabase if defined?(NullDB)

  before do
    class ActiveModelExtensionsTestModel1 < ModelBase
      include ActiveModelExtensions::Validations

      attr_accessor :name

      def initialize(options = {})
        @name = options[:name]
      end

      validate :validate_required

      def validate_required
        validate_required_fields 'name'
      end
    end
  end

  after { Object.send(:remove_const, klass.name) }

  let(:klass) { ActiveModelExtensionsTestModel1 }

  context 'when model missing name' do
    subject { klass.new }
    it { should_not be_valid }
  end

  context 'when model complete' do
    subject { klass.new(:name => 'Valid') }
    it { should be_valid }
  end
end

describe ActiveModelExtensions do
  include NullDB::CustomNullifiedDatabase if defined?(NullDB)

  before do
    class ActiveModelExtensionsTestModel2 < ModelBase
      include ActiveModelExtensions::Validations

      attr_accessor :name

      def initialize(options = {})
        @name = options[:name]
      end

      validate_mandatory_fields lambda { 'name' }
    end
  end

  after { Object.send(:remove_const, klass.name) }

  let(:klass) { ActiveModelExtensionsTestModel2 }

  context 'when model missing name' do
    subject { klass.new }
    it { should_not be_valid }
  end

  context 'when model complete' do
    subject { klass.new(:name => 'Valid') }
    it { should be_valid }
  end
end
