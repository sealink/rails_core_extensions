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

  let(:class_translation) { TranslationModel.t('display_me', name: 'Class') }
  subject { TranslationModel.new('Ruby') }

  specify { expect(TranslationModel.translation_key).to eq 'translation_model' }
  specify { expect(subject.to_s).to eq 'My name is Ruby' }
  specify { expect(class_translation).to eq 'My name is Class' }

  context 'performance' do
    before do
      allow(TranslationModel).to receive(:base_translation_class).and_call_original
      5.times { subject.to_s }
    end

    specify {
      expect(TranslationModel).to have_received(:base_translation_class).once
    }
  end

  context 'non AR subclass' do
    let(:model_subclass) {
      Class.new(model_class)
    }

    before do
      stub_const 'Translation::SubModel', model_subclass
    end

    let(:class_translation) { Translation::SubModel.t('display_me', name: 'Class') }
    subject { Translation::SubModel.new('Ruby') }

    specify { expect(Translation::SubModel.translation_key).to eq 'translation.sub_model' }
    specify { expect(subject.to_s).to eq 'My subname is Ruby' }
    specify { expect(class_translation).to eq 'My subname is Class' }
  end

  context 'AR base class' do
    let(:ar_model_class) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'parties'

        include RailsCoreExtensions::Translations

        def to_s
          t('display_me', name: name)
        end
      end
    }
    let(:ar_model_subclass) {
      Class.new(Party) do
        self.table_name = 'parties'

        include RailsCoreExtensions::Translations

        def to_s
          t('display_me', name: name)
        end
      end
    }

    before do
      connect_to_sqlite
      stub_const 'Party', ar_model_class
      stub_const 'Person', ar_model_subclass
    end

    let(:class_translation) { Party.t('display_me', name: 'Class') }
    subject { Party.new(name: 'Ruby') }

    specify { expect(Party.translation_key).to eq 'party' }
    specify { expect(subject.to_s).to eq 'Party Ruby' }
    specify { expect(class_translation).to eq 'Party Class' }

    context 'AR sub class' do
      let(:class_translation) { Person.t('display_me', name: 'Class') }
      subject { Person.new(name: 'Ruby') }

      specify { expect(Person.translation_key).to eq 'party' }
      specify { expect(subject.to_s).to eq 'Party Ruby' }
      specify { expect(class_translation).to eq 'Party Class' }
    end
  end
end
