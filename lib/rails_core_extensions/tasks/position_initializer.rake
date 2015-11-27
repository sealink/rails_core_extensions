namespace :fix do
  desc 'Fix acts as list positions if they ever get out of sync for a model'
  task :acts_as_list_positions => :environment do
    raise ArgumentError, 'You must specify model with MODEL environment variable' if ENV['MODEL'].nil?

    model_class     = ENV['MODEL'].camelize.constantize
    scope_name      = ENV['SCOPE'].try(:to_sym)
    position_column = ENV['POSITION'].try(:to_sym)

    PositionInitializer.positionalize(model_class, scope_name, position_column)
  end
end
