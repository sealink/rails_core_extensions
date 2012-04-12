module RailsCoreExtensions
  module ActionControllerRemoteBadSortable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def remote_bad_sortable
        include RailsCoreExtensions::ActionControllerRemoteBadSortable::InstanceMethods
      end
    end

    module InstanceMethods
      def move_higher
        move(params.slice(:type).merge(:direction => :higher))
      end

      def move_lower
        move(params.slice(:type).merge(:direction => :lower))
      end

      def move(options={})
        direction = options[:direction]

        o = current_object
        moved_ok = false
        Booking.transaction do
          o.lock!
          moved_ok = direction == :higher ? o.move_higher : o.move_lower
        end

        render :update do |page|
          if !moved_ok
            page.alert "This item can not be moved any #{direction}"
          else
            object_being_updated = o.reload

            other_object = if (direction == :higher)
              o.lower_item
            else
              o.higher_item
            end

            type = options[:type] || o.class.to_s.underscore
            dom_prefix = type

            page << <<-JS
              var row_being_updated = $("#{dom_prefix}_#{object_being_updated.id}");
              var other_row = $("#{dom_prefix}_#{other_object.id}");

              row_being_updated.replace(#{render(:partial => type, :locals => {type.to_sym => other_object}).to_json});
              other_row.replace(#{render(:partial => type, :locals => {type.to_sym => object_being_updated}).to_json});
            JS

            page["#{dom_prefix}_#{object_being_updated.id}"].highlight
            page["#{dom_prefix}_#{other_object.id}"].highlight
          end
        end
      rescue QuickTravelException, ActiveRecord::ActiveRecordError => e
        render :update do |page|
          page.alert(e.message)
        end
      end
    end
  end
end
