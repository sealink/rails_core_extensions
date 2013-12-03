module RailsCoreExtensions
  module Breadcrumb
    def breadcrumbs(object_or_nested_array = calculate_nested_array, path = objects_path, context = {})
      object = object_or_nested_array.is_a?(Array) ? object_or_nested_array.last : object_or_nested_array
      content_tag :ul, :class =>'breadcrumb' do
        content_tag(:li, link_to(object.class.table_name.titleize, path)) +
          object_breadcrumbs(object, context)
      end
    end

    def object_breadcrumbs(object, context)
      name = (object.respond_to?(:name) && !object.name.blank? ? object.name : object.to_s) unless object.new_record?
      if object.new_record?
        content_tag :li, 'New', :class => 'active'
      elsif context[:index]
        content_tag :li, name
      else
        (
          text = breadcrumb_can_show?(context) ? link_to(name, object) : name
          content_tag :li, text
        ) + (if action_edit?(context)
          content_tag :li, 'Edit', :class => 'active'
        end).to_s
      end
    end

    def calculate_nested_array
      namespaces + [current_object]
    end

    def breadcrumb_can_show?(context)
      (context[:can_show] || controller.respond_to?(:show)) && action_edit?(context)
    end

    def action_edit?(context)
      (context[:action] || params[:action]) == 'edit'
    end
  end
end

ActionView::Base.send(:include, RailsCoreExtensions::Breadcrumb) if defined?(ActionView::Base)
