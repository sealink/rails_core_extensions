module RailsCoreExtensions
  VERSION = '0.0.1'

  require 'active_record'
  require 'action_controller'

  require 'rails_core_extensions/caches_action_without_host'
  require 'rails_core_extensions/activatable'
  require 'rails_core_extensions/action_controller_sortable'
  require 'rails_core_extensions/action_controller_remote_bad_sortable'
  require 'rails_core_extensions/action_view_currency_extensions'
  require 'rails_core_extensions/action_view_has_many_extensions'
  require 'rails_core_extensions/action_view_extensions'
  require 'rails_core_extensions/active_model_extensions'
  require 'rails_core_extensions/active_record_cloning'
  require 'rails_core_extensions/active_record_cache_all_attributes'
  require 'rails_core_extensions/active_record_extensions'
  require 'rails_core_extensions/active_record_liquid_extensions'
  require 'rails_core_extensions/active_record_4_dynamic_finders_backport'
  require 'rails_core_extensions/date_time'
  require 'rails_core_extensions/date'
  require 'rails_core_extensions/time_with_zone'
  require 'rails_core_extensions/active_support_concern'
  require 'rails_core_extensions/concurrency'


  ActionController::Base.send(:include, CachesActionWithoutHost)
  ActionController::Base.send(:include, Activatable)
  ActionController::Base.send(:include, ActionControllerSortable)
  ActionController::Base.send(:include, ActionControllerRemoteBadSortable)
  ActiveRecord::Base.send(:include, ActiveRecordCloning)
  ActiveRecord::Base.send(:include, ActiveRecordExtensions)
  ActiveRecord::Base.send(:include, ActiveModelExtensions::Validations)
  ActiveRecord::Base.send(:include, RailsCoreExtensions::ActiveRecordLiquidExtensions)
  ActiveRecord::Base.send(:include, ActiveRecordExtensions::InstanceMethods)
  ActiveRecord::Base.send(:extend, ActiveRecord4DynamicFindersBackport) if ::ActiveRecord::VERSION::MAJOR == 3
end

