module ActiveRecordExtensions
  def self.included(base)
    base.extend(ClassMethods)
  end

  
  module ClassMethods
    def database(key)
      establish_connection("#{key}_#{Rails.env}")
    end

    def cache_all_attributes(options = {})
      method = options[:by] || 'id'
      class_eval <<-CACHE
        after_save :clear_attribute_cache
        after_destroy :clear_attribute_cache

        def clear_attribute_cache
          Rails.cache.delete("#{self.name}.attribute_cache") if self.class.should_cache?
        end

        def self.attribute_cache
          cache_key = "#{self.name}.attribute_cache"
          if self.should_cache?
            Rails.cache.read(cache_key) || self.generate_cache(cache_key)
          else
            self.generate_attributes_hash
          end
        end

        def self.generate_attributes_hash
          Hash[self.ordered.all.map { |o| [o.send("#{method}"), o.attributes] }]
        end

        def self.generate_cache(cache_key)
          if cache = generate_attributes_hash
            Rails.cache.write(cache_key, cache)
          end
          cache
        end

        def self.should_cache?
          Rails.configuration.action_controller.perform_caching
        end
      CACHE
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

    def restricted_by_right
      class << self
        def accessible_to(user)
          all.select{|o| user.rights.include?(o.right)}
        end
      end

      include RestrictedByRight

      belongs_to :right
      before_create :create_access_right!
      after_destroy :destroy_access_right!
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

    # Add a money field attribute
    #
    # By default it will use attribute_in_cents as db field, but this can
    # be overridden by specifying :db_field => 'somthing_else'
    def money_field(attribute, options={})
      db_field = options[:db_field] || attribute.to_s + '_in_cents'
      self.composed_of(attribute,
        :class_name => "Money",
        :allow_nil  => true,
        :mapping    => [[db_field, 'cents']],
        :converter  => Proc.new {|field| field.to_money}
      )
    end

    def money_fields(*attributes)
      attributes.each {|a| self.money_field(a)}
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


    # Cloning
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


    def translate(key, options = {})
      klass = self
      klass = klass.superclass while klass.superclass != ActiveRecord::Base
      I18n.translate key, options.merge(:scope => klass.name.tableize.singularize)
    end


    def t(key, options = {})
      self.translate(key, options)
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


    def to_drop
      @drop_class ||= (self.class.name+'Drop').constantize
      @drop_class.new(self)
    end
    alias_method :to_liquid, :to_drop


    def clone_excluding(excludes=[])
      cloned = clone

      excludes ||= []
      excludes = [excludes] unless excludes.is_a?(Enumerable)

      excludes.each do |excluded_attr|
        attr_writer = (excluded_attr.to_s + '=').to_sym
        cloned.send attr_writer, nil
      end

      cloned
    end


    # Validates the presence of the required fields identified in a rule-string.
    #
    # Similar to validates_presence_of macro, but is an INSTANCE method.
    # This allows it to vary depending on customised settings.
    #
    # Example:
    # validate_required_fields "field1,field2 or field4"
    #
    # The string is a CSV of required field rules, where each field rule is:
    #  - the name of a required field
    #  - OR a set of required field names spearated by 'or' (where only ONE is required)
    #
    def validate_required_fields(required_field_string, association = self)
      return if required_field_string.strip.blank?

      # Comma seperated list of field sets, where each field set *may* contain 'or'
      required_field_rules = required_field_string.split(',').map{|f| f.split(" or ").map(&:strip)}

      required_field_rules.each do |required_field_rule|
        # Find 'or' seperated fields
        next unless required_field_rule.all?{|field|
          if association.send(field) == false
            false
          else
            association.send(field).blank?
          end
        }

        if required_field_rule.size == 1
          errors.add(required_field_rule.first, "is required")
        else
          errors.add_to_base("One of %s is required" % required_field_rule.map(&:humanize).to_sentence)
        end
      end
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


    # Cloning

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

module RestrictedByRight
  private
  def create_access_right!
    self.right = Right.find_or_create_by_name(:name => "#{self.class.name.titleize}: #{name}")
  end

  def destroy_access_right!
    self.right.try(:destroy)
  end
end
