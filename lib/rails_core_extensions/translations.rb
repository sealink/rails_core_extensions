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
        @translation_key ||= base_translation_class.name.tableize.singularize
      end

      def base_translation_class
        return base_class if defined?(ActiveRecord) && ancestors.include?(ActiveRecord::Base)
        self
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
