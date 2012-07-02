module CachesActionWithoutHost

  def self.included(controller)
    controller.extend(ClassMethods)
  end

  module ClassMethods
    def caches_action_without_host(*args)
      options = args.extract_options!
      options ||= {}
      options[:cache_path] ||= proc{|c| c.url_for(c.params).split(/\//, 4).last}
      args << options
      caches_action(*args)
    end
  end

end
