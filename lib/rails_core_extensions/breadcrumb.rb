module RailsCoreExtensions

  module Breadcrumb

    def breadcrumbs(object_or_nested_array = nil)
      breadcrumbs_builder_for(object_or_nested_array).breadcrumbs
    end


    private

    def breadcrumbs_builder_for(object_or_nested_array)
      BreadcrumbsBuilder.new(self, object_or_nested_array)
    end


    class BreadcrumbsBuilder

      attr_reader :view, :object_or_nested_array, :path

      def initialize(view, object_or_nested_array = nil)
        @view                     =   view
        @object_or_nested_array   =   object_or_nested_array ||   path_builder.nested_array
        @path                     =   path_builder.collection_url
      end


      def breadcrumbs
        view.content_tag :ul, :class =>'breadcrumb' do
          (breadcrumb_for_parent + breadcrumb_for_collection + breadcrumb_for_action).html_safe
        end
      end


      def breadcrumb_for_object_link
        breadcrumb_for link_to_object
      end


      private

      def breadcrumb_for_parent
        parent = path_builder.parent
        return ''.html_safe unless parent
        BreadcrumbsBuilder.new(view, parent).breadcrumb_for_object_link
      end


      def breadcrumb_for_collection
        if action == 'index'
          breadcrumb_for view.params[:controller].titleize
        else
          breadcrumb_for view.link_to(object.class.table_name.titleize, path)
        end
      end


      def breadcrumb_for_action
        case action
          when 'new'    then breadcrumb_for('New', :class => 'active')
          when 'edit'   then breadcrumb_for_object_link + breadcrumb_for('Edit', :class => 'active')
          when 'index'  then nil
          else breadcrumb_for_object_name
        end
      end


      def breadcrumb_for(content, options = {})
        view.content_tag :li, content, options
      end


      def breadcrumb_for_object_name
        breadcrumb_for object_name.html_safe
      end


      def link_to_object
        if can_show?
          view.link_to object_name.html_safe, object_or_nested_array
        else
          object_name.html_safe
        end
      end


      def can_show?
        view.controller.respond_to?(:show)
      end


      def action
        return 'new' if object.new_record?
        view.params[:action]
      end


      def object_name
        if object.respond_to?(:name) && object.name.present?
          object.name
        else
          object.to_s
        end
      end


      def object
        @object ||= Array(object_or_nested_array).last
      end


      def path_builder
        @path_builder ||= if inherited_resources?
                            InheritedResourcesPathBuilder.new(view)
                          else
                            PathBuilder.new(view)
                          end
      end


      def inherited_resources?
        defined?(InheritedResources) && view.controller.responder == InheritedResources::Responder
      end

    end


    PathBuilder = Struct.new(:view) do
      def nested_array
        (namespaces + [parent] + [view.current_object]).compact
      end

      def collection_url
        view.objects_path
      end

      def parent
        view.parent_object
      end

      def namespaces
        return [] unless view.respond_to?(:namespaces)
        Array(view.namespaces)
      end
    end


    InheritedResourcesPathBuilder = Struct.new(:view) do
      def nested_array
        if view.respond_to? :calculate_nested_array
          view.calculate_nested_array
        elsif view.params[:action] == 'index'
          [parent]
        else
          [parent, view.resource].compact
        end
      end

      def collection_url
        view.collection_url
      end

      def parent
        return view.parent.becomes(view.parent.class.base_class) if view.respond_to?(:parent)
        view.parent_object
      end
    end

  end
end

ActionView::Base.send(:include, RailsCoreExtensions::Breadcrumb) if defined?(ActionView::Base)
