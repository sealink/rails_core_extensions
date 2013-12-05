module RailsCoreExtensions
  module Breadcrumb
    def breadcrumbs(object_or_nested_array = calculate_nested_array, path = calculate_collection_url, context = {})
      object = object_or_nested_array.is_a?(Array) ? object_or_nested_array.last : object_or_nested_array
      content_tag :ul, :class =>'breadcrumb' do
        (object_breadcrumbs(calculate_parent, :nested => true) if calculate_parent).to_s.html_safe +
          content_tag(:li, link_to(object.class.table_name.titleize, path)) +
          object_breadcrumbs(object_or_nested_array, context)
      end
    end

    def calculate_nested_array(*args)
      return [calculate_parent, resource].compact if inherited_resources?
      (namespaces + [calculate_parent] + [current_object]).compact
    end

    def calculate_collection_url
      return collection_url if inherited_resources?
      objects_path
    end

    def calculate_parent
      return parent if inherited_resources? && defined?(parent)
      parent_object
    end

    def inherited_resources?
      defined?(InheritedResources) && controller.responder == InheritedResources::Responder
    end

    def object_breadcrumbs(object_or_nested_array, context = {})
      object = object_or_nested_array.is_a?(Array) ? object_or_nested_array.last : object_or_nested_array
      name = (object.respond_to?(:name) && object.name.present? ? object.name : object.to_s) unless object.new_record?
      if object.new_record?
        content_tag :li, 'New', :class => 'active'
      elsif context[:index]
        content_tag :li, name
      elsif context[:nested]
        link_to(name, object_or_nested_array)
      else
        (
          text = breadcrumb_can_show?(context) ? link_to(name, object_or_nested_array) : name
          content_tag :li, text
        ) + (if action_edit?(context)
          content_tag :li, 'Edit', :class => 'active'
        end).to_s
      end
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
