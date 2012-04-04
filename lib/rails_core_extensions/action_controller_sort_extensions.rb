module ActionControllerSortExtensions

  def move_higher
    move(params.slice(:type).merge(:direction => :higher))
  end

  def move_lower
    move(params.slice(:type).merge(:direction => :lower))
  end

  def move(options={})
    direction = options[:direction]

    o = current_object
    moved_ok = false
    Booking.transaction do
      o.lock!
      moved_ok = direction == :higher ? o.move_higher : o.move_lower
    end

    render :update do |page|
      if !moved_ok
        page.alert "This item can not be moved any #{direction}"
      else
        object_being_updated = o.reload

        other_object = if (direction == :higher)
          o.lower_item
        else
          o.higher_item
        end

        type = options[:type] || o.class.to_s.underscore
        dom_prefix = type

        page << <<-JS
          var row_being_updated = $("#{dom_prefix}_#{object_being_updated.id}");
          var other_row = $("#{dom_prefix}_#{other_object.id}");

          row_being_updated.replace(#{render(:partial => type, :locals => {type.to_sym => other_object}).to_json});
          other_row.replace(#{render(:partial => type, :locals => {type.to_sym => object_being_updated}).to_json});
        JS

        page["#{dom_prefix}_#{object_being_updated.id}"].highlight
        page["#{dom_prefix}_#{other_object.id}"].highlight
      end
    end
  rescue QuickTravelException, ActiveRecord::ActiveRecordError => e
    render :update do |page|
      page.alert(e.message)
    end
  end
  
  def sort
    params_collection = if params[:scope]
      params["#{controller_name.singularize}_#{params[params[:scope]]}_body".to_sym]
    else
      params["#{controller_name.singularize}_body".to_sym]
    end
      
    if params_collection.blank?
      name = "#{params[:scope].gsub('_id', '')}_#{params[params[:scope]]}_body"
      params_collection = params[name]
    end

    klass = controller_name.classify.constantize
    collection = if params[:scope]
      klass.ordered.all(:conditions => params.slice(params[:scope].to_sym))
    else
      klass.ordered
    end

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

