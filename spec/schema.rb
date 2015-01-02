ActiveRecord::Schema.define(:version => 1) do
  create_table :models do |t|
    t.string :name
  end

  create_table :parents do |t|
  end

  create_table :children do |t|
    t.integer :parent_id
  end
end
