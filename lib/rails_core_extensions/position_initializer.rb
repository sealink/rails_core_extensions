module RailsCoreExtensions
  class PositionInitializer
    def self.positionalize(model_class, scope_name = nil, position_column = :position)
      position_column ||= :position
      objects = model_class.order(:position)
      groups = scope_name ? objects.group_by(&scope_name.to_sym).values : [objects]
      groups.each do |objects|
        objects.each.with_index do |object, index|
          if object.position != index + 1
            model_class.where(id: object.id).update_all(position_column => index + 1)
          end
        end
      end
    end
  end
end
