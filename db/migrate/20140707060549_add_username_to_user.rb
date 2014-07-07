class AddUsernameToUser < ActiveRecord::Migration
  def change
    add_column :user, :username, :string
    add_index :user, :username, unique: true
  end
end
