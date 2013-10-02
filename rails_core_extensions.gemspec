## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'rails_core_extensions'
  s.version           = '0.0.1'
  s.date              = '2013-10-02'
  s.rubyforge_project = 'rails_core_extensions'

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "Set of extensions to core rails libraries used by TravelLink Technology."
  s.description = "These are extensions from core rails classes."

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Michael Noack", "Alessandro Berardi"]
  s.email    = 'development@travellink.com.au'
  s.homepage = 'http://github.com/sealink/rails_core_extensions'
  s.license  = 'MIT'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## This sections is only necessary if you have C extensions.
  # s.require_paths << 'ext'
  # s.extensions = %w[ext/extconf.rb]

  ## If your gem includes any executables, list them here.
  # s.executables = ["name"]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  s.add_dependency('activerecord', [">= 2.3.0", "< 5.0.0"])
  s.add_dependency('actionpack', [">= 2.3.0", "< 5.0.0"])

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  # s.add_development_dependency('DEVDEPNAME', [">= 1.1.0", "< 2.0.0"])

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    LICENSE
    README.md
    Rakefile
    gemfiles/rails2.gemfile
    gemfiles/rails3.gemfile
    gemfiles/rails4.gemfile
    lib/rails_core_extensions.rb
    lib/rails_core_extensions/action_controller_remote_bad_sortable.rb
    lib/rails_core_extensions/action_controller_sortable.rb
    lib/rails_core_extensions/action_view_currency_extensions.rb
    lib/rails_core_extensions/action_view_extensions.rb
    lib/rails_core_extensions/action_view_has_many_extensions.rb
    lib/rails_core_extensions/activatable.rb
    lib/rails_core_extensions/active_record_4_dynamic_finders_backport.rb
    lib/rails_core_extensions/active_record_cache_all_attributes.rb
    lib/rails_core_extensions/active_record_cloning.rb
    lib/rails_core_extensions/active_record_extensions.rb
    lib/rails_core_extensions/active_record_liquid_extensions.rb
    lib/rails_core_extensions/active_support_concern.rb
    lib/rails_core_extensions/caches_action_without_host.rb
    lib/rails_core_extensions/concurrency.rb
    lib/rails_core_extensions/date.rb
    lib/rails_core_extensions/date_time.rb
    lib/rails_core_extensions/time_with_zone.rb
    rails_core_extensions.gemspec
    spec/active_record_extensions_spec.rb
    spec/concurrency_spec.rb
    spec/date_spec.rb
    spec/date_time_spec.rb
    spec/schema.rb
    spec/spec_helper.rb
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
