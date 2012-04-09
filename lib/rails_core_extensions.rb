module RailsCoreExtensions
  VERSION = '0.0.1'

  require 'active_record'
  require 'action_controller'

  require 'rails_core_extensions/action_controller_extensions'
  require 'rails_core_extensions/action_controller_sort_extensions'
  require 'rails_core_extensions/action_view_currency_extensions'
  require 'rails_core_extensions/action_view_has_many_extensions'
  require 'rails_core_extensions/active_record_cloning'
  require 'rails_core_extensions/active_record_extensions'
  require 'rails_core_extensions/active_record_migration_extensions'

  ActionController::Base.send(:include, ActionControllerExtensions)
  ActionController::Base.send(:include, ActionControllerSortExtensions)
  ActiveRecord::Base.send(:include, ActiveRecordCloning)
  ActiveRecord::Base.send(:include, ActiveRecordExtensions)
  ActiveRecord::Base.send(:include, ActiveRecordExtensions::InstanceMethods)
end

