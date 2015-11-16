ActiveRecord::Schema.define(:version => 1) do
  create_table :models do |t|
    t.string :name
    t.string :age
  end

  create_table :parents do |t|
  end

  create_table :children do |t|
    t.string :name
    t.integer :parent_id
    t.integer :position
  end
end
