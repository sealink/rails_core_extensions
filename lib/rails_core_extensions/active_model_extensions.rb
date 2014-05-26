module ActiveModelExtensions
  module Validations
    def self.included(base)
      base.extend ClassMethods
    end

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
    class CustomPresenceValidator < ActiveModel::Validator
      def validate(record)
        required_fields = Array.wrap(@options[:attributes]).first.call || []
        return if required_fields.empty?

        required_fields.flatten.each do |required_field|
          if required_field.include? ' or '
            fields = required_field.split(' or ')
            if fields.all? { |field| record.send(field).to_s.blank? }
              record.errors.add(:base, "One of %s is required" % fields.map(&:humanize).to_sentence)
            end
          else
            if record.send(required_field).to_s.blank?
              record.errors.add(required_field, "is required")
            end
          end
        end

      end
    end

    module ClassMethods
      def validate_presence_by_custom_rules(*with)
        validates_with CustomPresenceValidator, _merge_attributes(with)
      end
    end
  end
end
