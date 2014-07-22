class AddIndexToRule < ActiveRecord::Migration
  def change
    add_index :rule, [:product, :rule], unique: true, length: {product: 50}
  end
end
