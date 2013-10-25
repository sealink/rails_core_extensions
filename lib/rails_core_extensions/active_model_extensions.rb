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
    def validate_required_fields(required_field_string)
      return if required_field_string.strip.blank?

      # Comma separated list of field sets, where each field set *may* contain 'or'
      required_field_rules = required_field_string.split(',').map { |f| f.split(" or ").map(&:strip) }

      required_field_rules.each do |required_field_rule|
        if required_field_rule.all? { |field| self.send(field).to_s.blank? }
          if required_field_rule.size == 1
            errors.add(required_field_rule.first, "is required")
          else
            errors.add(:base, "One of %s is required" % required_field_rule.map(&:humanize).to_sentence)
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
