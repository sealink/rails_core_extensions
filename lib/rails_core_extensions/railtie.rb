module RailsCoreExtensions
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'rails_core_extensions/tasks/position_initializer.rake'
    end
  end
end
