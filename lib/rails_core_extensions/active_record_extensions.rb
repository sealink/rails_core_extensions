module ActiveRecordExtensions
  def self.included(base)
    base.extend(ClassMethods)
  end

  
  module ClassMethods
    # Like establish_connection but postfixes the key with the rails environment
    # e.g. database('hello') in development will look for the database
    #      which in config/database.yml is called hello_development
    def database(key)
      establish_connection("#{key}_#{Rails.env}")
    end

    def cache_all_attributes(options = {})
      method = options[:by] || 'id'
      class_eval <<-CACHE
        after_save :clear_attribute_cache
        after_destroy :clear_attribute_cache
        cattr_accessor :cache_attributes_by
        self.cache_attributes_by = '#{method}'
      CACHE
      extend ActiveRecordCacheAllAttributes::ClassMethods
      include ActiveRecordCacheAllAttributes::InstanceMethods
    end

    # Create a new object from the attributes passed in
    # OR update an existing
    #
    # If an :id attribute is present it will assume it's an existing record, and needs update
    def new_or_update!(hash={}, options = {:hard_update => true})
      hash.symbolize_keys!
      if hash[:id].blank?
        self.new(hash)
      else
        rec = self.find(hash[:id])
        if options[:hard_update]
          rec.update_attributes!(hash.except(:id))
        else
          rec.update_attributes(hash.except(:id))
        end
        rec
      end
    end
    
    def enum(field, values, options = {})
      const_set("#{field.to_s.upcase}_OPTIONS", values)
      
      select_options = if values.is_a?(Array)
        values.map.with_index{|v, i| [v.to_s.humanize, i]}
      elsif values.is_a?(Hash)
        values.values.map.with_index{|v, i| [v, i]}
      end
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
      cattr_accessor :enabled_fields
      self.enabled_fields = Array.wrap(Setting.send("#{self.to_s.underscore}_optional_fields")).map { |f| f.to_s.to_sym }
      
      possible_fields.each do |field|
        instance_eval <<-EVAL
          def #{field}_enabled?
            enabled_fields.include?(:#{field})
          end
        EVAL
      end
    end

    # Add a WeekDays attribute
    #
    # By default it will use attribute_bit_array as db field, but this can
    # be overridden by specifying :db_field => 'somthing_else'
    def weekdays_field(attribute, options={})
      db_field = options[:db_field] || attribute.to_s + '_bit_array'
      self.composed_of(attribute,
        :class_name => "WeekDays",
        :mapping    => [[db_field, 'weekdays_int']],
        :converter  => Proc.new {|field| WeekDays.new(field)}
      )
    end

    def acts_as_seasonal
      belongs_to :season
      accepts_nested_attributes_for :season
      validates_associated :season

      named_scope :season_on, lambda {|date = Date.current| {
        :joins => {:season => :date_groups},
        :conditions => ["date_groups.start_date <= ? AND date_groups.end_date >= ?", date, date]
      }}

      named_scope :available_from, lambda {|date = Date.current| {
        :conditions => ["boundary_end >= ?", date]
      }}

      before_save do |object|
        if object.season
          object.boundary_start = object.season.boundary_start
          object.boundary_end   = object.season.boundary_end
        end
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


    # Validates presence of -- but works on parent within accepts_nested_attributes
    #
    def validates_presence_of_parent(foreign_key)
      after_save do |record|
        unless record.send(foreign_key)
          record.errors.add_on_blank(foreign_key)
          raise ActiveRecord::ActiveRecordError, record.errors.full_messages.to_sentence
        end
      end
    end


    # Run a block, being respectful of connection pools
    #
    # Useful for when you're not in the standard rails request process,
    # since normally rails will take, then clear you're connection in the
    # processing of the request.
    #
    # If you don't do this in, say, a command line task with threads, then
    # you'll run out of connections after 5 x Threads are run simultaneously...
    def with_connection_pooling
      # Verify active connections and remove and disconnect connections
      # associated with stale threads.
      ActiveRecord::Base.verify_active_connections!

      yield

      # This code checks in the connection being used by the current thread back
      # into the connection pool. It repeats this if you are using multiple
      # connection pools. It will not disconnect the connection.
      #
      # Returns any connections in use by the current thread back to the pool,
      # and also returns connections to the pool cached by threads that are no
      # longer alive.
      ActiveRecord::Base.clear_active_connections!

    end


    def translate(key, options = {})
      klass = self
      klass = klass.superclass while klass.superclass != ActiveRecord::Base
      I18n.translate key, options.merge(:scope => klass.name.tableize.singularize)
    end


    def t(key, options = {})
      self.translate(key, options)
    end

  end

  
  module InstanceMethods


    def all_errors
      errors = {}
      self.errors.each do |attr, msg|
        errors[attr] = if (record_attr = self.send(attr)).is_a?(ActiveRecord::Base)
          record_attr.all_errors
        else
          msg
        end
      end
      errors
    end


    def to_drop
      @drop_class ||= (self.class.name+'Drop').constantize
      @drop_class.new(self)
    end
    alias_method :to_liquid, :to_drop


    # Validates the presence of the required fields identified in a rule-string.
    #
    # Similar to validates_presence_of macro, but is an INSTANCE method.
    # This allows it to vary depending on custom settings.
    #
    # Example:
    # validate_required_fields "field1,field2 or field4"
    #
    # The string is a CSV of required field rules, where each field rule is:
    #  - the name of a required field
    #  - OR a set of required field names spearated by 'or' (where only ONE is required)
    #
    def validate_required_fields(required_field_string)
      return if required_field_string.strip.blank?

      # Comma separated list of field sets, where each field set *may* contain 'or'
      required_field_rules = required_field_string.split(',').map { |f| f.split(" or ").map(&:strip) }
      
      required_field_rules.each do |required_field_rule|
        if required_field_rule.all? { |field| self.send(field).to_s.blank? }
          if required_field_rule.size == 1
            errors.add(required_field_rule.first, "is required")
          else
            errors.add_to_base("One of %s is required" % required_field_rule.map(&:humanize).to_sentence)
          end
        end
      end
    end
    
        
    def self.find_model_by_attribute(attribute)
      return self if self.column_names.include?(attribute.to_s)
      found = nil
      reflect_on_all_associations do |association|
        found = association.find_model_by_attribute(attribute)
      end
      found
    end


    # Generate attributes in a hash, leaning on active records serializer,
    #
    # You can use :include, :except/:only, :methods like in to_json
    def to_hash(options={})
      ActiveRecord::Serialization::Serializer.new(self, options).serializable_record
    end


    # A unique id - even if you are unsaved!
    def unique_id
      id || @generated_dom_id || (@generated_dom_id = Time.now.to_f.to_s.gsub('.', '_'))
    end


    #getting audits
    def audit_log
      return (self.methods.include?('audits') ? self.audits : [])
    end



    private

    def t(key, options = {})
      self.class.translate(key, options)
    end


    def transfer_records(klass, objects, options = {})
      record_ids = objects.map{|o|
        o.send(klass.name.underscore + '_ids')
      }.flatten
      unless record_ids.empty?
        options[:foreign_key] ||= self.class.name.underscore + '_id'
        update_options = options.except(:foreign_key)
        update_options[options[:foreign_key]] = id
        klass.update_all(update_options, :id => record_ids)
      end
    end

  end

end
