module ActiveRecordExtensions
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Like establish_connection but postfixes the key with the rails environment
    # e.g. database('hello') in development will look for the database
    #      which in config/database.yml is called hello_development
    def database(key)
      establish_connection("#{key}_#{Rails.env}")
    end

    def enum_int(field, values, options = {})
      const_set("#{field.to_s.upcase}_OPTIONS", values)

      select_options = values.map.with_index{|v, i| [v.to_s.humanize, i]}
      const_set("#{field.to_s.upcase}_SELECT_OPTIONS", select_options)

      values.each.with_index do |value, i|
        const_set("#{field.to_s.upcase}_#{value.to_s.upcase}", i)
        method_name = options[:short_name] ? "#{value}?" : "#{field}_#{value}?"
        class_eval <<-ENUM
          def #{method_name}
            #{field} == #{i}
          end
        ENUM
      end
      class_eval <<-ENUM
        def #{field}_name
          #{field.to_s.upcase}_OPTIONS[#{field}]
        end
      ENUM
    end

    def optional_fields(*possible_fields)
      @optional_fields_loader = possible_fields.pop if possible_fields.last.is_a?(Proc)

      class << self
        def enabled_fields
          @enabled_fields || @optional_fields_loader.try(:call)
        end

        def enabled_fields=(fields)
          @enabled_fields = fields
        end
      end

      possible_fields.each do |field|
        instance_eval <<-EVAL
          def #{field}_enabled?
            enabled_fields.include?(:#{field})
          end
        EVAL
      end
    end

    def position_helpers_for(*collections)
      collections.each do |collection|
        class_eval <<-EVAL
          after_save do |record|
            record.rebalance_#{collection.to_s.singularize}_positions!
          end

          def assign_#{collection.to_s.singularize}_position(object)
            object.position = (#{collection}.last.try(:position) || 0) + 1 unless object.position
          end

          def rebalance_#{collection.to_s.singularize}_positions!(object = nil)
            reload
            #{collection}.sort_by(&:position).each_with_index do |o, index|
              if o.position != (index + 1)
                o.update_attribute(:position, index + 1)
              end
            end
          end
        EVAL
      end
    end
  end

  module InstanceMethods
    def all_errors
      errors_hash = {}
      self.errors.each do |attr, msg|
        (errors_hash[attr] ||= []) << if self.respond_to?(attr) && (record_attr = self.send(attr)).is_a?(ActiveRecord::Base)
          record_attr.all_errors
        else
          msg
        end
      end
      errors_hash
    end

    def to_drop
      @drop_class ||= (self.class.name+'Drop').constantize
      @drop_class.new(self)
    end
    alias_method :to_liquid, :to_drop

    # A unique id - even if you are unsaved!
    def unique_id
      id || @generated_dom_id || (@generated_dom_id = Time.now.to_f.to_s.gsub('.', '_'))
    end

    #getting audits
    def audit_log
      return (self.methods.include?('audits') ? self.audits : [])
    end
  end
end
