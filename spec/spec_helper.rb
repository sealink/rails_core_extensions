# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper.rb"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'rubygems'
require 'bundler/setup'
require 'support/coverage_loader'

require 'action_controller'
require 'active_record'

require 'rails_core_extensions'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = :random
end

DB_FILE = 'tmp/test_db'
def connect_to_sqlite
  return if ActiveRecord::Base.connected?

  FileUtils.mkdir_p File.dirname(DB_FILE)
  FileUtils.rm_f DB_FILE

  ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => DB_FILE
  load('spec/schema.rb')
end
