module RailsCoreExtensions
  class PositionInitializer
    def initialize(model_class, scope_name = nil, position_column = nil)
      @model_class = model_class
      @scope_name = scope_name
      @position_column = position_column
      @position_column ||= :position
    end

    def positionalize
      groups.each do |objects|
        objects.each.with_index do |object, index|
          next if object.position == index + 1
          scope = @model_class.where(id: object.id)
          scope.update_all(@position_column => index + 1)
        end
      end
    end

    private

    def groups
      objects = @model_class.order(@position_column)
      @scope_name ? objects.group_by(&@scope_name.to_sym).values : [objects]
    end
  end
end
