class CreateCategory < ActiveRecord::Migration
  def change
    create_table :category do |t|
      t.string :title
      t.integer :user_id
      t.boolean :published

      t.timestamps
    end

    create_table :category_rule do |t|
      t.references :rule
      t.references :category

      t.timestamps
    end

    add_index "category_rule", ["category_id", "rule_id"], name: "index_rule_on_category_rule", unique: true
  end
end
