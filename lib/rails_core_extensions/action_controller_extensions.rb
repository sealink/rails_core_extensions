module ActionControllerExtensions

  def self.included(controller)
    controller.extend(ClassMethods)
  end

  module ClassMethods
    def caches_action_without_host(*args)
      options = args.extract_options!
      options ||= {}
      options[:cache_path] ||= proc{|c| c.url_for(c.params).split(/\//, 4).last}
      args << options
      caches_action(*args)
    end
  end

  def activate(success_block = nil)
    current_object.active = params[:active] || false
    current_object.save!
    if success_block
      success_block.call
    else
      flash[:success] = "#{current_object} #{params[:active] ? 'activated' : 'inactivated'}"
      redirect_to(objects_path)
    end
  rescue ActiveRecord::ActiveRecordError, QuickTravelException => e
    current_object.errors.add_to_base("Failed to inactivate: " + e.message)
    flash[:error] = current_object.errors.full_messages.to_sentence
    redirect_to(objects_path)
  end

end

