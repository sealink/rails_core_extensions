module RailsCoreExtensions
  module ActiveRecordLiquidExtensions
    def self.included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def validates_liquid(field)
      field = field.to_sym
      before_validation do |record|
        begin
          Liquid::Template.parse(record.send(field))
        rescue Liquid::SyntaxError => e
          record.errors.add(field, "Liquid Syntax Error: #{e}")
        end
      end
    end

    def liquid_field(field)
      class_eval <<-CODE
        def parsed_#{field}
          Liquid::Template.parse(#{field})
        end

        def render_#{field}(*args)
          parsed_#{field}.render!(*args)
        end
      CODE
    end
  end
end
