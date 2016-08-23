require 'spec_helper'
require 'i18n'

describe 'translations' do
  let(:model_class) {
    Class.new do
      include RailsCoreExtensions::Translations

      def initialize(name)
        @name = name
      end

      def to_s
        t('display_me', name: @name)
      end
    end
  }

  before do
    stub_const 'TranslationModel', model_class
  end

  let(:class_translation) { TranslationModel.translate('display_me', name: 'Class') }
  subject { TranslationModel.new('Ruby') }

  specify { expect(subject.to_s).to eq 'My name is Ruby' }
  specify { expect(class_translation).to eq 'My name is Class' }
end
