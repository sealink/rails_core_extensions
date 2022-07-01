module RailsCoreExtensions
  module ActionControllerSortable
    extend ActiveSupport::Concern

    module ClassMethods
      def sortable
        include RailsCoreExtensions::ActionControllerSortable::InstanceMethods
      end
    end

    module InstanceMethods
      def sort
        RailsCoreExtensions::Sortable.new(params, controller_name).sort
        head :ok
      end
    end
  end
end
