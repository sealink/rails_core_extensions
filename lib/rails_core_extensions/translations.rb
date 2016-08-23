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
        (base_activerecord_class || base_ruby_class).name.tableize.singularize
      end

      def base_activerecord_class
        return unless defined?(ActiveRecord) && is_a?(ActiveRecord::Base)
        klass = self
        while klass.superclass != ActiveRecord::Base
          klass = klass.superclass
        end
        klass
      end

      def base_ruby_class
        klass = self
        while klass.superclass != Object
          klass = klass.superclass
        end
        klass
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
