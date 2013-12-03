begin
require 'active_model'
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
        CustomPresenceValidator.new(:attributes => lambda { ['name'] }).validate(self)
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
    it { should be_nil }
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

      validate_presence_by_custom_rules lambda { ['name'] }
    end

    class ActiveModelExtensionsTestModel3 < ModelBase
      include ActiveModelExtensions::Validations

      attr_accessor :name, :phone, :mobile

      def initialize(options = {})
        @name = options[:name]
        @phone = options[:phone]
        @mobile = options[:mobile]

      end

      validate_presence_by_custom_rules lambda { ['name', 'phone or mobile'] }
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

  context 'with or case' do
    let(:klass) { ActiveModelExtensionsTestModel3 }

    context 'when model has none of conditions' do
      subject { klass.new(:name => 'Valid') }
      it { should_not be_valid }
    end

    context 'when model has first of conditions' do
      subject { klass.new(:name => 'Valid', :phone => '555-1234') }
      it { should be_valid }
    end

    context 'when model has second of conditions' do
      subject { klass.new(:name => 'Valid', :mobile => '555-1234') }
      it { should be_valid }
    end

    context 'when model has all conditions' do
      subject { klass.new(:name => 'Valid', :phone => '555-1234', :mobile => '555-4321') }
      it { should be_valid }
    end
  end
end

rescue LoadError # Spec doesn't run for rails 2
end
