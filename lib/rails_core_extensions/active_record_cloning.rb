module ActiveRecordCloning
  extend ActiveSupport::Concern

  module ClassMethods

    def inherited(subclass)
      super
      subclass.cloned_attributes_hash = cloned_attributes_hash
    end

    def attributes_included_in_cloning
      cloned_attributes_hash[:include].dup
    end

    def attributes_excluded_from_cloning
      cloned_attributes_hash[:exclude].dup
    end

    def clones_attributes(*attributes)
      cloned_attributes_hash[:include] = attributes.map(&:to_sym)
    end

    def clones_attributes_except(*attributes)
      cloned_attributes_hash[:exclude] = attributes.map(&:to_sym)
    end

    def clones_attributes_reset
      @cloned_attributes = nil
    end

    def exclude_attributes(cloned, excludes)
      excluded_attributes(excludes).each do |attr|
        cloned.send("#{attr}=", nil)
      end
    end

    def excluded_attributes(excludes)
      all_attributes = attribute_names.map(&:to_sym)
      included_attributes = if attributes_included_in_cloning.empty?
        all_attributes
      else
        all_attributes & attributes_included_in_cloning
      end
      all_attributes - included_attributes + attributes_excluded_from_cloning + excludes
    end

    protected

    def cloned_attributes_hash
      @cloned_attributes ||= {:include => [], :exclude => []}
    end

    def cloned_attributes_hash=(attributes_hash)
      @cloned_attributes = attributes_hash
    end

  end

  def clone_excluding(excludes=[])
    method = ActiveRecord::Base.instance_methods(false).include?(:clone) ? :clone : :dup
    cloned = send(method)
    excludes ||= []
    excludes = [excludes] unless excludes.is_a?(Enumerable)
    self.class.exclude_attributes(cloned, excludes)
    cloned
  end
end
