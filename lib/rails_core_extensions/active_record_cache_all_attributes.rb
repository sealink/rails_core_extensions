module ActiveRecordCacheAllAttributes
  def self.included(base)
    base.extend ClassMethods
  end

  module InstanceMethods
    def clear_attribute_cache
      self.class.cache.delete("#{self.class.name}.attribute_cache") if self.class.should_cache?
    end
  end

  module ClassMethods
    def cache
      Rails.cache
    end

    def attribute_cache
      cache_key = "#{self.name}.attribute_cache"
      if self.should_cache?
        cache.read(cache_key) || self.generate_cache(cache_key)
      else
        self.generate_attributes_hash
      end
    end

    def generate_attributes_hash
      scope = self
      scope.ordered if respond_to?(:ordered) #scopes[:ordered]
      Hash[scope.all.map { |o| [o.send(self.cache_attributes_by), o.attributes] }]
    end

    def generate_cache(cache_key)
      if (cache_value = generate_attributes_hash)
        cache.write(cache_key, cache_value)
      end
      cache_value
    end

    def should_cache?
      Rails.configuration.action_controller.perform_caching
    end
  end
end
