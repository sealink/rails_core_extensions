#ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, )

# a little hack to dry up our migrations when we're removing a ton of individual columns
module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      def remove_columns(table_name, *columns)
        columns.each { |column| remove_column table_name, column }
      end

      def add_columns(table_name, type, *columns)
        columns.each { |column| add_column table_name, column, type}
      end
    end
  end
end


