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
        RailsCoreExtensions::Sortable.new(params, controller_name).sort
        head :ok
      end
    end
  end
end
