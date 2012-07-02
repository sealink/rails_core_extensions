module Activatable

  def self.included(controller)
    controller.extend(ClassMethods)
  end

  module ClassMethods
    def activatable
      include Activatable::InstanceMethods
    end
  end

  module InstanceMethods
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
      current_object.errors.add(:base, "Failed to inactivate: " + e.message)
      flash[:error] = current_object.errors.full_messages.to_sentence
      redirect_to(objects_path)
    end
  end

end
