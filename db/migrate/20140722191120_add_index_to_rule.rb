class AddIndexToRule < ActiveRecord::Migration
  def change
    add_index :rule, [:user_id, :product, :rule], unique: true, length: {product: 50}
  end
end
