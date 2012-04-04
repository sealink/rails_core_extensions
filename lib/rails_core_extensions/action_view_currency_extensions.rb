module ActionView
  module Helpers
    module FormTagHelper
      # Create currency selector tag -- see select_tag for options
      def currency_select_tag(name, current_value, options={})
        selectable_options = []
        selectable_options << ["--", nil] if options[:include_blank]
        selectable_options += EnabledCurrency.all.map(&:iso_code) unless EnabledCurrency.all.empty?
        select_tag(name, options_for_select(selectable_options, current_value), options)
      end
    end

    module DateHelper
      def currency_select(object_name, method, options = {})
        value = options[:object] || EnabledCurrency.base_currency
        currency_select_tag("#{object_name}[#{method}]", value, options.merge(:id => "#{object_name}_#{method}")) 
      end
    end

    class FormBuilder
      def currency_select(method, options = {})
        @template.currency_select(@object_name, method, options.merge(:object => @object.send(method)))
      end
    end
  end
end
