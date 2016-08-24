module RailsCoreExtensions
  module Translations
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def translate(key, options = {})
        I18n.translate key, options.merge(scope: translation_key)
      end

      def translation_key
        base_translation_class.name.tableize.singularize
      end

      def base_translation_class
        klass = self
        while !base_classes.include? klass.superclass
          klass = klass.superclass
        end
        klass
      end

      def base_classes
        return [ActiveRecord::Base, Object] if defined?(ActiveRecord)
        [Object]
      end

      def t(key, options = {})
        self.translate(key, options)
      end
    end

    private

    def t(key, options = {})
      self.class.translate(key, options)
    end
  end
end
