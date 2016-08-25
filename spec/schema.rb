ActiveRecord::Schema.define(:version => 1) do
  create_table :models do |t|
    t.string :name
    t.string :age
    t.integer :position
    t.integer :category_id
  end

  create_table :parties do |t|
    t.string :name, :type
  end

  create_table :parents do |t|
  end

  create_table :children do |t|
    t.string :name
    t.integer :parent_id
    t.integer :position
  end
end
