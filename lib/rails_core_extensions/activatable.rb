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
      resource.active = params[:active] || false
      resource.save!
      if success_block
        success_block.call
      else
        flash[:success] = "#{resource} #{params[:active] ? 'activated' : 'inactivated'}"
        redirect_to(collection_path)
      end
    rescue ActiveRecord::ActiveRecordError => e
      resource.errors.add(:base, "Failed to inactivate: " + e.message)
      flash[:error] = resource.errors.full_messages.to_sentence
      redirect_to(collection_path)
    end
  end

end
