class AddUserIdToRule < ActiveRecord::Migration
  def change
    add_column :rule, :user_id, :integer
  end
end
