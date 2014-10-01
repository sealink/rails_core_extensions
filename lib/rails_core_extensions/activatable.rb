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
      resource.active = params[:active].presence || false
      action = resource.active ? 'activate' : 'inactivate'

      resource.save!

      success_block ||= -> {
        flash[:success] = "#{resource} #{action}d"
        redirect_to(collection_path)
      }

      success_block.call

    rescue ActiveRecord::ActiveRecordError => e
      resource.errors.add(:base, "Failed to #{action}: " + e.message)
      flash[:error] = resource.errors.full_messages.to_sentence
      redirect_to(collection_path)
    end

  end

end
