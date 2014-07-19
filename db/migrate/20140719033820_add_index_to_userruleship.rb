class AddIndexToUserruleship < ActiveRecord::Migration
  def change
    add_index :userruleship, [:user_id, :rule_id], unique: true
  end
end
