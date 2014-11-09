class AddDurationToUser < ActiveRecord::Migration
  def change
    add_column :user, :duration, :datetime
    add_column :userhost, :user_id, :integer
  end
end
