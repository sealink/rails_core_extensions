module RailsCoreExtensions
  class Sortable
    # params is either:
    # SIMPLE:
    #   model_body (where model is the model name)
    # SCOPED:
    #   scope (name of the scope, e.g. category_id)
    #   category_id (or whatever the name of scope is)
    #   model_1_body (or whatever id of scope id)
    def initialize(params, controller_name)
      @params = params.permit!.to_h.symbolize_keys
      @controller_name = controller_name
      @klass = controller_name.classify.constantize
    end

    def sort
      scope = @params[:scope].try(:to_sym)
      @params[scope] = nil if @params[scope].blank?

      body_key = @controller_name.singularize + (@params[scope] ? "_#{@params[scope]}" : '')
      sorted_id_list = @params["#{body_key}_body".to_sym]
      if sorted_id_list.blank?
        sorted_id_list = @params["#{scope.to_s.gsub('_id', '')}_#{@params[scope]}_body".to_sym]
      end

      collection = @klass.reorder(:position)
      collection = collection.where(@params.slice(scope)) unless scope.blank?

      sort_collection(collection.find(sorted_id_list.map(&:to_i)), sorted_id_list.map(&:to_i))
    end

    private

    def sort_collection(collection_old, collection_new_ids)
      @klass.transaction do
        collection_old.each.with_index do |object, index|
          next if object.id == collection_new_ids[index]

          new_position = collection_new_ids.index(object.id) + 1
          update(object, new_position)
        end
      end
    end

    def update(object, new_position)
      @klass.find(object.id).update_attribute(:position, new_position)
    end
  end
end
