class AddKeyToUser < ActiveRecord::Migration
  def change
    add_column :user, :key, :string
  end
end
