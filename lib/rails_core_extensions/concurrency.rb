module Concurrency
  extend ActiveSupport::Concern
  
  module ClassMethods
    
    def concurrency_safe(*methods)
      options = methods.extract_options!
      methods.each do |method|
        add_concurrency_check(method, options)
      end
    end
    
    
    def concurrency_safe_method_locked?(method)
      concurrency_cache.read(concurrency_safe_method_cache_name(method)) == 'locked'
    end
    
    
    def concurrency_cache
      @concurrency_cache ||= ::Rails.cache
    end
    
    
    def concurrency_cache=(cache)
      [:read,:write,:delete].each do |method|
        raise ConcurrencyCacheException, "#{cache} does not implement #{method}" unless cache.respond_to?(method)
      end
      @concurrency_cache = cache
    end
    
    
    private
    
    def add_concurrency_check(method, options = {})
      method_definition = <<-DEFINITION
        def #{method}_with_concurrency_lock(*args)
          if concurrency_safe_method_locked?(:#{method})
            raise ConcurrentCallException.new(self,:#{method}), "#{self.name}.#{method} is already running"
          end
          lock_concurrency_safe_method(:#{method})
          return_value = nil
          begin
            return_value = #{method}_without_concurrency_lock(*args)
          ensure
            unlock_concurrency_safe_method(:#{method})
          end
          return_value
        end

        alias_method_chain :#{method}, :concurrency_lock
      DEFINITION
      
      if method_type(method, options[:type]) == 'class'
        method_definition = <<-DEFINITION
          class << self
            #{method_definition}
          end
        DEFINITION
      end
      
      module_eval method_definition
    end
    
    
    def lock_concurrency_safe_method(method)
      concurrency_cache.write(concurrency_safe_method_cache_name(method), 'locked')
    end
    
    
    def unlock_concurrency_safe_method(method)
      concurrency_cache.delete(concurrency_safe_method_cache_name(method))
    end
    
    
    def concurrency_safe_method_cache_name(method)
      "#{self.name.underscore}_concurrency_safe_class_method_#{method}"
    end
    
    
    def method_type(method, type = nil)
      types = method_types(method, type)
      raise AmbiguousMethodException.new(self, method), "#{method} for #{self.name} is ambiguous. Please specify the type (instance/class) option" if types.count == 2
      raise NoMethodException.new(self, method), "#{method} is not not a valid method for #{self.name}." if types.blank?
      types.first
    end
    
    
    def method_types(method, type = nil)
      ['class', 'instance'].select do |mt|
        (type.blank? || type.to_s == mt) && self.send("#{mt}_method?", method)
      end
    end
    
    
    def class_method?(method)
      self.respond_to?(method, true)
    end
    
    
    def instance_method?(method)
      (self.instance_methods + self.private_instance_methods).map(&:to_s).include?(method.to_s)
    end
    
  end
  
  
  module InstanceMethods
    
    def concurrency_cache
      self.class.concurrency_cache
    end
    
    
    def concurrency_safe_method_locked?(method)
      concurrency_cache.read(concurrency_safe_method_cache_name(method)) == 'locked'
    end
    
    
    private
    
    def lock_concurrency_safe_method(method)
      concurrency_cache.write(concurrency_safe_method_cache_name(method), 'locked')
    end
    
    
    def unlock_concurrency_safe_method(method)
      concurrency_cache.delete(concurrency_safe_method_cache_name(method))
    end
    
    
    def concurrency_safe_method_cache_name(method)
      "#{self.class.name.underscore}_concurrency_safe_instance_method_#{method}"
    end
    
  end
  
  
  class ConcurrencyException < ::Exception; end
  class ConcurrencyCacheException < ConcurrencyException; end
  class MethodException < ConcurrencyException
    attr_reader :object, :method
    
    def initialize(object, method)
      @object = object
      @method = method
    end
  end
  class ConcurrentCallException < MethodException; end
  class NoMethodException < MethodException; end
  class AmbiguousMethodException < MethodException; end
    
end