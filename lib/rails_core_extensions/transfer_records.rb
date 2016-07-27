module RailsCoreExtensions
  class TransferRecords
    def initialize(parent, klass, options = {})
      @parent = parent
      @klass = klass
      @options = options
    end

    def transfer_from(objects)
      record_ids = objects.flat_map { |o|
        o.send(@klass.name.underscore + '_ids')
      }
      unless record_ids.empty?
        @options[:foreign_key] ||= @parent.class.name.underscore + '_id'
        update_options = @options.except(:foreign_key)
        update_options[@options[:foreign_key]] = @parent.id
        @klass.where(id: record_ids).update_all(update_options)
      end
    end
  end
end
