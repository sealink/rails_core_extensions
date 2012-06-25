module ActiveRecordCloning

  def self.included(base)
    base.extend(ClassMethods)
  end

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

    protected

    def cloned_attributes_hash
      @cloned_attributes ||= {:include => [], :exclude => []}
    end

    def cloned_attributes_hash=(attributes_hash)
      @cloned_attributes = attributes_hash
    end

  end

  module InstanceMethods

    def self.included(base)
      base.class_eval %q{
        alias_method :base_clone_attributes, :clone_attributes
        def clone_attributes(reader_method = :read_attribute, attributes = {})
          allowed = cloned_attributes
          base_clone_attributes(reader_method, attributes).delete_if { |k,v| !allowed.include?(k.to_sym) }
        end
      }
    end

    def clone_excluding(excludes=[])
      cloned = respond_to?(:dup) ? dup : clone

      excludes ||= []
      excludes = [excludes] unless excludes.is_a?(Enumerable)

      excludes.each do |excluded_attr|
        attr_writer = (excluded_attr.to_s + '=').to_sym
        cloned.send attr_writer, nil
      end

      cloned
    end

    private

    def cloned_attributes
      included_attributes = if self.class.attributes_included_in_cloning.empty?
        attribute_names.map(&:to_sym)
      else
        attribute_names.map(&:to_sym) & self.class.attributes_included_in_cloning
      end
      included_attributes - self.class.attributes_excluded_from_cloning
    end
  end

end
