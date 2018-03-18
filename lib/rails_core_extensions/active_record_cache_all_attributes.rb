module ActiveRecordCacheAllAttributes
  def self.included(base)
    base.extend ClassMethods
  end

  module InstanceMethods
    def clear_attribute_cache
      self.class.cache.delete("#{self.class.name}.attribute_cache")
    end
  end

  module ClassMethods
    def cache
      Rails.cache
    end

    def attribute_cache
      cache_key = "#{self.name}.attribute_cache"
      cache.read(cache_key) || self.generate_cache(cache_key)
    end

    def generate_attributes_hash
      scope = self
      scope = scope.ordered if respond_to?(:ordered)
      Hash[scope.all.map { |o| [o.send(self.cache_attributes_by), o.attributes] }]
    end

    def generate_cache(cache_key)
      cache_value = generate_attributes_hash
      cache.write(cache_key, cache_value)
      cache_value
    end
  end
end
