# Helper defines a active-model like model so tests can work in rails2/3 environments
begin
  require 'active_model'
  class ModelBase
    include ActiveModel::Validations
  end
rescue LoadError # can't load active_model, so rails < 3
  require 'active_record'
  class ModelBase < ActiveRecord::Base
  end

  require 'nulldb_rspec'

  # Custom NullDB so can reconnect to regular adapter after running
  module NullDB::CustomNullifiedDatabase
    def self.included(spec_example)
      spec_example.before :all do
        ActiveRecord::Base.establish_connection :adapter => :nulldb, :schema => 'spec/schema.rb'
      end

      spec_example.before :each do
        ActiveRecord::Base.connection.checkpoint!
      end

      spec_example.after :all do
        ActiveRecord::Base.remove_connection

        begin
          connect_to_sqlite
        rescue ActiveRecord::AdapterNotSpecified
          # swallow reconnection when running in nulldb / lite environment
          # without any app boot, and hence no db config for :test
        end
      end
    end
  end
end
