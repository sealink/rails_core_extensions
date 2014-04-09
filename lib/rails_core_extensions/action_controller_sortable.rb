module RailsCoreExtensions
  module ActionControllerSortable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def sortable
        include RailsCoreExtensions::ActionControllerSortable::InstanceMethods
      end
    end

    module InstanceMethods
      def sort
        scope = params[:scope]

        param_key = controller_name.singularize
        param_key += "_#{params[scope]}" if scope

        params_collection = params["#{param_key}_body".to_sym]

        if params_collection.blank?
          name = "#{scope.gsub('_id', '')}_#{params[scope]}_body"
          params_collection = params[name]
        end

        klass = controller_name.classify.constantize
        collection = klass.order(:position)
        collection = collection.scoped(:conditions => params.slice(scope.to_sym)) if scope

        sort_collection(collection, params_collection)

        render :update do |page|
        end
      end

      private

      def sort_collection(collection_old, collection_new)
        klass = collection_old.first.class
        collection_old.each_with_index do |o, index|
          if o.id != collection_new[index].to_i
            new_position = collection_new.index(o.id.to_s) + 1
            klass.update_all("position = #{new_position}", "id = #{o.id}", :limit => 1)
          end
        end
      end
    end
  end
end
