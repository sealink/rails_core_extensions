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
    def validate_required_fields(required_fields)
      return if required_fields.empty?

      required_fields.each do |required_field|
        if required_field.include? ' or '
          fields = required_field.split(' or ')
          if fields.all? { |field| send(field).to_s.blank? }
            errors.add(:base, "One of %s is required" % fields.map(&:humanize).to_sentence)
          end
        else
          if send(required_field).to_s.blank?
            errors.add(required_field, "is required")
          end
        end
      end
    end

    module ClassMethods
      def validate_mandatory_fields(with)
        validate { |m| m.validate_required_fields(with.call) }
      end
    end
  end
end
