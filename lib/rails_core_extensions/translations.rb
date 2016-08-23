module RailsCoreExtensions
  module Translations
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def translate(key, options = {})
        I18n.translate key, options.merge(scope: base_class.name.tableize.singularize)
      end

      def base_class
        klass = self
        while klass.superclass != ActiveRecord::Base && klass.superclass != Object
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
