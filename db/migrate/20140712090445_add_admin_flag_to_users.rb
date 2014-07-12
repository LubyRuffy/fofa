class AddAdminFlagToUsers < ActiveRecord::Migration
  def change
    add_column :user, :isadmin, :bool
  end
end
