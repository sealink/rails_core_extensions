module ActiveRecordCacheAllAttributes
  def self.included(base)
    base.extend ClassMethods
  end

  module InstanceMethods
    def clear_attribute_cache
      self.class.cache.delete("#{self.class.name}.attribute_cache")
      self.class.clear_request_cache
    end
  end

  module ClassMethods
    def cache
      Rails.cache
    end

    def clear_request_cache
      @request_cache = nil
    end

    def attribute_cache
      cache_key = "#{name}.attribute_cache"
      @request_cache ||= cache.read(cache_key) || generate_cache(cache_key)
    end

    def generate_attributes_hash
      scope = self
      scope = scope.ordered if respond_to?(:ordered)
      Hash[scope.all.map { |o| [o.send(cache_attributes_by), o.attributes] }]
    end

    def generate_cache(cache_key)
      cache_value = generate_attributes_hash
      cache.write(cache_key, cache_value)
      cache_value
    end
  end
end
