module RailsCoreExtensions
  require 'rails_core_extensions/sortable'
  require 'rails_core_extensions/position_initializer'
  require 'rails_core_extensions/time_with_zone'
  require 'rails_core_extensions/transfer_records'

  require 'rails_core_extensions/railtie' if defined?(Rails)

  if defined? ActionController
    require 'rails_core_extensions/activatable'
    require 'rails_core_extensions/action_controller_sortable'

    ActiveSupport.on_load(:action_controller) do
      ActionController::Base.send(:include, Activatable)
      ActionController::Base.send(:include, ActionControllerSortable)
    end
  end

  if defined? ActionView
    require 'rails_core_extensions/action_view_extensions'
    require 'rails_core_extensions/action_view_has_many_extensions'

    ActiveSupport.on_load(:action_view) do
      ActionView::Base.send(:include, RailsCoreExtensions::ActionViewExtensions)
    end
  end

  if defined? ActiveRecord
    require 'rails_core_extensions/active_record_cloning'
    require 'rails_core_extensions/active_record_extensions'
    require 'rails_core_extensions/active_record_liquid_extensions'
    require 'rails_core_extensions/translations'
    require 'rails_core_extensions/active_model_extensions'

    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Base.send(:include, ActiveRecordCloning)
      ActiveRecord::Base.send(:include, ActiveRecordExtensions)
      ActiveRecord::Base.send(:include, RailsCoreExtensions::ActiveRecordLiquidExtensions)
      ActiveRecord::Base.send(:include, ActiveRecordExtensions::InstanceMethods)
      ActiveRecord::Base.send(:include, RailsCoreExtensions::Translations)
      ActiveRecord::Base.send(:include, ActiveModelExtensions::Validations)
    end
  end
end
