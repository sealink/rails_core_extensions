module ActionView
  module Helpers
    module DateHelper
      def hm_check_box(object_name, method, options = {})
        object = options.delete(:object)
        parent = options.delete(:parent) || instance_variable_get(object_name)
        objects = options.delete(:objects) || parent.send(method)
        check_box_tag("#{object_name}[#{method}][]", object, objects.include?(object), options.merge(:id => "#{object_name}_#{method}"))
      end

      def hm_empty_array(object_name, method)
        hidden_field_tag "#{object_name}[#{method}][]"
      end
    end

    class FormBuilder
      def hm_empty_array(method)
        @habtm_fields ||= {}
        @habtm_fields[method] = @object.send(method)
        @template.hm_empty_array(@object_name, method)
      end

      def hm_check_box(method, object, options = {})
        empty = (hm_empty_array(method) unless @habtm_fields && @habtm_fields[method])
        (empty || '').html_safe + @template.hm_check_box(@object_name, method, options.merge(:object => object, :parent => @object, :objects => @habtm_fields[method]))
      end
    end
  end
end

